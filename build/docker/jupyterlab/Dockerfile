FROM base
LABEL maintainer="Thomas Mann <thomas.mann@kenbun.de>"

# -- Layer: Image Metadata

ARG build_date

LABEL org.label-schema.build-date=${build_date}
LABEL org.label-schema.name="Apache Spark Standalone Cluster on Docker - JupyterLab Image"
LABEL org.label-schema.description="JupyterLab image"
LABEL org.label-schema.url="https://github.com/kenbuntraining/spark-cluster-on-docker"
LABEL org.label-schema.schema-version="1.0"

# -- Layer: Notebooks and data

ADD workspace/ ${SHARED_WORKSPACE}/

# -- Layer: JupyterLab + Python kernel for PySpark

ARG spark_version
ARG jupyterlab_version
ARG scala_kernel_version
ARG postgres_version

RUN apt-get update -y && \
    apt-get install -y python3-pip python3-dev && \
    pip3 install --upgrade pip && \
    pip3 install wget==3.2 pyspark==${spark_version} jupyterlab==${jupyterlab_version}

# ML Layer
RUN pip3 install numpy pandas mlflow

# Streaming Tools Layer
RUN apt-get install -y netcat

# more ML/DL Layer
# RUN apt-get install cmake -y
# RUN pip3 install horovod horovod[spark]
# RUN pip3 install tensorflow
# RUN pip3 install torch pytorch_lightning

# -- Layer: Scala kernel for Spark

ARG scala_version

RUN apt-get install -y ca-certificates-java --no-install-recommends && \
    curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier launch --fork almond:${scala_kernel_version} --scala ${scala_version} -- --display-name "Scala ${scala_version}" --install && \
    rm -f coursier

# -- Layer: R kernel for SparkR

RUN apt-get install -y r-base-dev && \
    R -e "install.packages('IRkernel')" && \
    R -e "IRkernel::installspec(displayname = 'R 3.5', user = FALSE)" && \
    curl https://archive.apache.org/dist/spark/spark-${spark_version}/SparkR_${spark_version}.tar.gz -k -o sparkr.tar.gz && \
    R CMD INSTALL sparkr.tar.gz && \
    rm -f sparkr.tar.gz

## Database Layer

RUN curl https://jdbc.postgresql.org/download/postgresql-${postgres_version}.jar -o postgresql-${postgres_version}.jar && \
    mv postgresql-${postgres_version}.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

## Streaming / Kafka Layer

RUN curl https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/${spark_version}/spark-sql-kafka-0-10_2.12-${spark_version}.jar -o spark-sql-kafka-0-10_2.12-${spark_version}.jar && \
    mv spark-sql-kafka-0-10_2.12-${spark_version}.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

RUN curl https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/2.8.1/kafka-clients-2.8.1.jar -o kafka-clients-2.8.1.jar && \
    mv kafka-clients-2.8.1.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

RUN curl https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar -o commons-pool2-2.11.1.jar && \
    mv commons-pool2-2.11.1.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

RUN curl https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.12/${spark_version}/spark-token-provider-kafka-0-10_2.12-${spark_version}.jar -o spark-token-provider-kafka-0-10_2.12-${spark_version}.jar && \
    mv spark-token-provider-kafka-0-10_2.12-${spark_version}.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

## Avro Layer

RUN curl https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.12//${spark_version}/spark-avro_2.12-${spark_version}.jar -o spark-avro_2.12-${spark_version}.jar && \
    mv spark-avro_2.12-${spark_version}.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

#RUN curl https://repo1.maven.org/maven2/org/apache/avro/avro/1.11.1/avro-1.11.1.jar -o avro-1.11.1.jar && \
#    mv avro-1.11.1.jar /usr/local/lib/python3.9/dist-packages/pyspark/jars

## Metrics Layer

COPY metrics.training.properties /usr/training/metrics.training.properties

# -- Runtime

EXPOSE 8888
EXPOSE 5000

WORKDIR ${SHARED_WORKSPACE}

CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=