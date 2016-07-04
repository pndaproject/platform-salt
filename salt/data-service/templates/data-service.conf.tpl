start on runlevel [2345]
stop on runlevel [016]
normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2
setuid hdfs
chdir {{ install_dir }}/data-service
env programDir={{ install_dir }}/data-service
exec python ${programDir}/apiserver.py
