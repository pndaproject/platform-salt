# Ubuntu upstart file at /etc/init/hbase-conf.conf

description "HBase {{ daemon_service }} service"

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

exec /usr/hdp/current/hbase-master/bin/hbase-daemon.sh foreground_start {{ daemon_service }} -p {{ daemon_port }} --infoport {{ info_port }}
