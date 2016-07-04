start on runlevel [2345]
stop on runlevel [016]
respawn
respawn limit unlimited
post-stop exec sleep 2
setuid logger
env confFile={{ install_dir }}/logstash/shipper.conf
env programDir={{ install_dir }}/logstash
exec ${programDir}/bin/logstash -f ${confFile}