{
 "display_name": "PySpark2/Python2 (Anaconda)",
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
  "SPARK_MAJOR_VERSION":"2",
  "SPARK_HOME": "{{ wrapper_spark_home }}",
  "WRAPPED_SPARK_HOME": "{{ spark2_home }}",
  "PYTHONPATH": "{{ app_packages_home }}/lib/python2.7/site-packages:{{ jupyter_extension_venv }}/lib/python2.7/site-packages:{{ spark2_home }}/python:{{ spark2_home }}/python/lib/py4j.zip",
  "PYTHONSTARTUP": "{{ spark2_home }}/python/pyspark/shell.py",
  "PYSPARK_SUBMIT_ARGS": "--master yarn-client --jars {{ spark2_home }}/examples/jars/spark2_examples.jar pyspark-shell"
 }
}
