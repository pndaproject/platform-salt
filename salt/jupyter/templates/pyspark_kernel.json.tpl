{
 "display_name": "PySpark/Python2 (Anaconda)",
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
  "SPARK_HOME": "/opt/cloudera/parcels/CDH/lib/spark",
  "PYTHONPATH": "/opt/cloudera/parcels/CDH/lib/spark/python:/opt/cloudera/parcels/CDH/lib/spark/python/lib/py4j-0.9-src.zip",
  "PYTHONSTARTUP": "/opt/cloudera/parcels/CDH/lib/spark/python/pyspark/shell.py",
  "PYSPARK_SUBMIT_ARGS": "--master yarn-client --jars /opt/cloudera/parcels/CDH/lib/spark/lib/spark-examples.jar pyspark-shell"
 }
}
