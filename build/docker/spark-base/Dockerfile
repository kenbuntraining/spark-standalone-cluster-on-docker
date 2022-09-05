FROM base
LABEL maintainer="Thomas Mann <thomas.mann@kenbun.de>"

# -- Layer: Image Metadata

ARG build_date

LABEL org.label-schema.build-date=${build_date}
LABEL org.label-schema.name="Apache Spark Standalone Cluster on Docker - Spark Base Image"
LABEL org.label-schema.description="Spark base image shipped Spark"
LABEL org.label-schema.url="https://github.com/kenbuntraining/spark-cluster-on-docker"
LABEL org.label-schema.schema-version="1.0"

# -- Layer: Apache Spark

ARG spark_version
ARG hadoop_version
ARG postgres_version

RUN curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-${spark_version}-bin-hadoop${hadoop_version} /usr/bin/ && \
    echo "alias pyspark=/usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/bin/pyspark" >> ~/.bashrc && \
    echo "alias spark-shell=/usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/bin/spark-shell" >> ~/.bashrc && \
    mkdir /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/logs && \
    rm spark.tgz

## Database Layer

RUN curl https://jdbc.postgresql.org/download/postgresql-${postgres_version}.jar -o postgresql-${postgres_version}.jar && \
    mv postgresql-${postgres_version}.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

## Streaming / Kafka Layer

RUN curl https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/${spark_version}/spark-sql-kafka-0-10_2.12-${spark_version}.jar -o spark-sql-kafka-0-10_2.12-${spark_version}.jar && \
    mv spark-sql-kafka-0-10_2.12-${spark_version}.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

RUN curl https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/2.8.1/kafka-clients-2.8.1.jar -o kafka-clients-2.8.1.jar && \
    mv kafka-clients-2.8.1.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

RUN curl https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar -o commons-pool2-2.11.1.jar && \
    mv commons-pool2-2.11.1.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

RUN curl https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.12/${spark_version}/spark-token-provider-kafka-0-10_2.12-${spark_version}.jar -o spark-token-provider-kafka-0-10_2.12-${spark_version}.jar && \
    mv spark-token-provider-kafka-0-10_2.12-${spark_version}.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

## Avro Layer

RUN curl https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.12//${spark_version}/spark-avro_2.12-${spark_version}.jar -o spark-avro_2.12-${spark_version}.jar && \
    mv spark-avro_2.12-${spark_version}.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

#RUN curl https://repo1.maven.org/maven2/org/apache/avro/avro/1.11.1/avro-1.11.1.jar -o avro-1.11.1.jar && \
#    mv avro-1.11.1.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

# ML/DL Layer
#
# RUN apt-get update -y && \
#     apt-get install -y python3-pip python3-dev && \
#     pip3 install --upgrade pip
# 
# RUN pip3 install pyspark==${spark_version}
# 
# RUN apt-get install cmake -y
# RUN pip3 install horovod horovod[spark]
# RUN pip3 install tensorflow
# RUN pip3 install torch pytorch_lightning

ENV SPARK_HOME /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

COPY metrics.training.properties /usr/training/metrics.training.properties

# -- Runtime

WORKDIR ${SPARK_HOME}