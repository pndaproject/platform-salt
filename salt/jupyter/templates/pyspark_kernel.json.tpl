{
 "display_name": "PySpark/Python2 (Anaconda)",
 "language": "python",
 "argv": [
  "{{ anaconda_home }}/bin/python",
  "-m",
  "ipykernel",
  "-f",
  "{connection_file}"
 ],
 "env": {
  "HADOOP_CONF_DIR":"{{ hadoop_conf_dir }}",
  "PYSPARK_PYTHON":"{{ anaconda_home }}/bin/python",
  "SPARK_HOME": "{{ spark_home }}",
  "PYTHONPATH": "{{ spark_home }}/python:{{ spark_home }}/python/lib/py4j-0.9-src.zip",
  "PYTHONSTARTUP": "{{ spark_home }}/python/pyspark/shell.py",
  "PYSPARK_SUBMIT_ARGS": "--master yarn-client --jars {{ spark_home }}/lib/spark-examples*.jar pyspark-shell"
 }
}