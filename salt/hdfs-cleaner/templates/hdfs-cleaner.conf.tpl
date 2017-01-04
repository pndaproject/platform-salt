description "HDFS cleaner task"

task

setuid hdfs

env programDir={{ install_dir }}/hdfs-cleaner
env PYTHON_HOME={{ install_dir }}/hdfs-cleaner/venv

chdir {{ install_dir }}/hdfs-cleaner
exec ${PYTHON_HOME}/bin/python ${programDir}/hdfs-cleaner.py
