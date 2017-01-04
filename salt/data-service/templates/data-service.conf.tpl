start on runlevel [2345]
stop on runlevel [016]
normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2
setuid hdfs

env PYTHON_HOME={{ install_dir }}/data-service/venv

chdir {{ install_dir }}/data-service
env programDir={{ install_dir }}/data-service
exec ${PYTHON_HOME}/bin/python ${programDir}/apiserver.py
