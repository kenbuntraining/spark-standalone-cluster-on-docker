# How to find current "compatible" Hadoop Version based on Spark Version?

Check here: (based on your desired Version)

https://archive.apache.org/dist/spark/spark-3.3.0/

search for spark-3.3.-0-bin-hadoop<VERSION>.tgz

=> UPDATE in BUILD.SH

HADOOP_VERSION="3"

# How to find current "compatible" Scala Version based on Spark Version?

Check here:

Enter a Spark Worker Container

go towards e.g.

/usr/bin/spark-3.3.0-bin-hadoop3/jars

list for scala-library

extract a version from e.g.

scala-library-2.12.15.jar

=> UPDATE in BUILD.SH

SCALA_VERSION="2.12.15"

# How to find current "compatible" Scala Kernel for JupyterLAB?

Check here:

https://hub.docker.com/r/almondsh/almond/tags

select based on SCALA Version inferred from SPARK Version

there is specific tags for SCALA Versions

Reference:

https://github.com/almond-sh/almond

=> UPDATE in BUILD.SH

SCALA_JUPYTERLAB_KERNEL_VERSION="0.13.0-scala-2.12.15"