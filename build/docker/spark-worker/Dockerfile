ARG spark_version
FROM spark-base:${spark_version}
LABEL maintainer="Thomas Mann <thomas.mann@kenbun.de>"

# -- Layer: Image Metadata

ARG build_date

LABEL org.label-schema.build-date=${build_date}
LABEL org.label-schema.name="Apache Spark Standalone Cluster on Docker - Spark Worker Image"
LABEL org.label-schema.description="Spark Worker Image"
LABEL org.label-schema.url="https://github.com/kenbuntraining/spark-cluster-on-docker"
LABEL org.label-schema.schema-version="1.0"

# -- Runtime

EXPOSE 8081

CMD bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> logs/spark-worker.out
