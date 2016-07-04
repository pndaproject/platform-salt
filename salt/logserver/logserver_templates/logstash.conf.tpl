start on runlevel [2345]
stop on runlevel [016]
respawn
respawn limit unlimited
post-stop exec sleep 2
env confFile={{ install_dir }}/logstash/collector.conf
env programDir={{ install_dir }}/logstash
exec ${programDir}/bin/logstash -f ${confFile}