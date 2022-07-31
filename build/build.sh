#!/bin/bash
#
# -- Build Apache Spark Standalone Cluster Docker Images

# ----------------------------------------------------------------------------------------------------------------------
# -- Variables ---------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

if [[ "$OSTYPE" == "darwin"* ]]; then
  # MACOS Users
  # have to install another grep version (GNU Version) (not included in MacOS only BSD version is included)
  # with e.g. "brew install grep"
  GNU_GREP_TOOL="ggrep"
else
  GNU_GREP_TOOL="grep"
fi

BUILD_DATE="$(date -u +'%Y-%m-%d')"

SHOULD_BUILD_BASE="$(grep -m 1 build_base build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"
SHOULD_BUILD_SPARK="$(grep -m 1 build_spark build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"
SHOULD_BUILD_JUPYTERLAB="$(grep -m 1 build_jupyter build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

SHOULD_TAG="$(grep -m 1 tag build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"
SHOULD_PUSH="$(grep -m 1 push build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

IMAGE_REPOSITORY="$(grep -m 1 imagerepository build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

SPARK_VERSION="$(grep -m 1 spark build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"
JUPYTERLAB_VERSION="$(grep -m 1 jupyterlab build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

POSTGRESQL_VERSION="$(grep -m 1 postgresql build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

SPARK_VERSION_MAJOR=${SPARK_VERSION:0:1}

if [[ "${SPARK_VERSION_MAJOR}" == "2" ]]
then
  HADOOP_VERSION="2.7"
  SCALA_VERSION="2.11.12"
  SCALA_JUPYTERLAB_KERNEL_VERSION="0.6.0"
elif [[ "${SPARK_VERSION_MAJOR}"  == "3" ]]
then
  HADOOP_VERSION="3.2"
  SCALA_VERSION="2.12.10"
  SCALA_JUPYTERLAB_KERNEL_VERSION="0.10.9"
  if [[ "${SPARK_VERSION}" == "3.3.0" ]]
  then
    HADOOP_VERSION="3"
    SCALA_VERSION="2.12.15"
    SCALA_JUPYTERLAB_KERNEL_VERSION="0.13.0"
  fi
else
  exit 1
fi

# ----------------------------------------------------------------------------------------------------------------------
# -- Functions----------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

function cleanContainers() {

    container="$(docker ps -a | grep 'jupyterlab' | awk '{print $1}')"
    docker stop "${container}"
    docker rm "${container}"

    container="$(docker ps -a | grep 'spark-worker' -m 1 | awk '{print $1}')"
    while [ -n "${container}" ];
    do
      docker stop "${container}"
      docker rm "${container}"
      container="$(docker ps -a | grep 'spark-worker' -m 1 | awk '{print $1}')"
    done

    container="$(docker ps -a | grep 'spark-master' | awk '{print $1}')"
    docker stop "${container}"
    docker rm "${container}"

    container="$(docker ps -a | grep 'spark-base' | awk '{print $1}')"
    docker stop "${container}"
    docker rm "${container}"

    container="$(docker ps -a | grep 'base' | awk '{print $1}')"
    docker stop "${container}"
    docker rm "${container}"

}

function cleanImages() {

    if [[ "${SHOULD_BUILD_JUPYTERLAB}" == "true" ]]
    then
      docker rmi -f "$(docker images | grep -m 1 'jupyterlab' | awk '{print $3}')"
    fi

    if [[ "${SHOULD_BUILD_SPARK}" == "true" ]]
    then
      docker rmi -f "$(docker images | grep -m 1 'spark-worker' | awk '{print $3}')"
      docker rmi -f "$(docker images | grep -m 1 'spark-master' | awk '{print $3}')"
      docker rmi -f "$(docker images | grep -m 1 'spark-base' | awk '{print $3}')"
    fi

    if [[ "${SHOULD_BUILD_BASE}" == "true" ]]
    then
      docker rmi -f "$(docker images | grep -m 1 'base' | awk '{print $3}')"
    fi

}

function cleanVolume() {
  docker volume rm "hadoop-distributed-file-system"
}

function buildImages() {

  if [[ "${SHOULD_BUILD_BASE}" == "true" ]]
  then
    docker build \
      --build-arg build_date="${BUILD_DATE}" \
      --build-arg scala_version="${SCALA_VERSION}" \
      -f docker/base/Dockerfile \
      -t base:latest .
  fi

  if [[ "${SHOULD_BUILD_SPARK}" == "true" ]]
  then

    docker build \
      --build-arg build_date="${BUILD_DATE}" \
      --build-arg spark_version="${SPARK_VERSION}" \
      --build-arg hadoop_version="${HADOOP_VERSION}" \
      --build-arg postgres_version="${POSTGRESQL_VERSION}" \
      -f docker/spark-base/Dockerfile \
      -t spark-base:${SPARK_VERSION} .

    docker build \
      --build-arg build_date="${BUILD_DATE}" \
      --build-arg spark_version="${SPARK_VERSION}" \
      -f docker/spark-master/Dockerfile \
      -t spark-master:${SPARK_VERSION} .

    docker build \
      --build-arg build_date="${BUILD_DATE}" \
      --build-arg spark_version="${SPARK_VERSION}" \
      -f docker/spark-worker/Dockerfile \
      -t spark-worker:${SPARK_VERSION} .

  fi

  if [[ "${SHOULD_BUILD_JUPYTERLAB}" == "true" ]]
  then
    docker build \
      --build-arg build_date="${BUILD_DATE}" \
      --build-arg scala_version="${SCALA_VERSION}" \
      --build-arg spark_version="${SPARK_VERSION}" \
      --build-arg jupyterlab_version="${JUPYTERLAB_VERSION}" \
      --build-arg scala_kernel_version="${SCALA_JUPYTERLAB_KERNEL_VERSION}" \
      --build-arg postgres_version="${POSTGRESQL_VERSION}" \
      -f docker/jupyterlab/Dockerfile \
      -t jupyterlab:${JUPYTERLAB_VERSION}-spark-${SPARK_VERSION} .
  fi

}

function tagImages() {

  if [[ "${SHOULD_BUILD_SPARK}" == "true" ]]
  then

    docker tag spark-base:${SPARK_VERSION} ${IMAGE_REPOSITORY}/spark-base:${SPARK_VERSION}
    docker tag spark-master:${SPARK_VERSION} ${IMAGE_REPOSITORY}/spark-master:${SPARK_VERSION}
    docker tag spark-worker:${SPARK_VERSION} ${IMAGE_REPOSITORY}/spark-worker:${SPARK_VERSION}

  fi

  if [[ "${SHOULD_BUILD_JUPYTERLAB}" == "true" ]]
  then
    docker tag jupyterlab:${JUPYTERLAB_VERSION}-spark-${SPARK_VERSION} ${IMAGE_REPOSITORY}/jupyterlab:${JUPYTERLAB_VERSION}-spark-${SPARK_VERSION}
  fi

}

function pushImages() {

  if [[ "${SHOULD_BUILD_SPARK}" == "true" ]]
  then

    docker push ${IMAGE_REPOSITORY}/spark-base:${SPARK_VERSION}
    docker push ${IMAGE_REPOSITORY}/spark-master:${SPARK_VERSION}
    docker push ${IMAGE_REPOSITORY}/spark-worker:${SPARK_VERSION}

  fi

  if [[ "${SHOULD_BUILD_JUPYTERLAB}" == "true" ]]
  then
    docker push ${IMAGE_REPOSITORY}/jupyterlab:${JUPYTERLAB_VERSION}-spark-${SPARK_VERSION}
  fi

}

# ----------------------------------------------------------------------------------------------------------------------
# -- Main --------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

cleanContainers;
cleanImages;
cleanVolume;
buildImages;

if [[ "${SHOULD_TAG}" == "true" ]]
then
  tagImages;
fi

if [[ "${SHOULD_PUSH}" == "true" ]]
then
  pushImages;
fi