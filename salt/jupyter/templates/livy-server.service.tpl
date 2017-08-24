description "livy server start as service"

task

setuid livy

env programDir={{ install_dir }}/bin
env SPARK_HOME={{ spark_home }}
env HADOOP_CONF_DIR={{ hadoop_conf_dir }}

chdir {{ install_dir }}/bin
exec ${PYTHON_HOME}/bin/python ${programDir}/hdfs-cleaner.py
