{
 "display_name": "PySpark (Python2)",
 "language": "python",
 "argv": [
  "/opt/cloudera/parcels/Anaconda/bin/python",
  "-m",
  "ipykernel",
  "-f",
  "{connection_file}"
 ],
 "env": {
  "HADOOP_CONF_DIR":"/etc/hadoop/conf.cloudera.yarn01",
  "PYSPARK_PYTHON":"/opt/cloudera/parcels/Anaconda/bin/python",
  "SPARK_HOME": "/opt/cloudera/parcels/CDH-5.5.2-1.cdh5.5.2.p0.4/lib/spark",
  "PYTHONPATH": "/opt/cloudera/parcels/CDH-5.5.2-1.cdh5.5.2.p0.4/lib/spark/python:/opt/cloudera/parcels/CDH-5.5.2-1.cdh5.5.2.p0.4/lib/spark/python/lib/py4j-0.8.2.1-src.zip",
  "PYTHONSTARTUP": "/opt/cloudera/parcels/CDH-5.5.2-1.cdh5.5.2.p0.4/lib/spark/python/pyspark/shell.py",
  "PYSPARK_SUBMIT_ARGS": "--master yarn-client --jars /opt/cloudera/parcels/CDH-5.5.2-1.cdh5.5.2.p0.4/lib/spark/lib/spark-examples.jar pyspark-shell"
 }
}