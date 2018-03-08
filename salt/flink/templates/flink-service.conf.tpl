# Upstart file at /etc/init/flink-history-service.conf
description "Flink-History-Server Service"

start on runlevel [2345]
stop on runlevel [016]

normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2

setuid pnda
setgid pnda

chdir {{ install_dir }}
pre-start exec bin/historyserver.sh start
post-stop exec bin/historyserver.sh stop

