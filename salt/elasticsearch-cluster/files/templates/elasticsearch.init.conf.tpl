# Ubuntu upstart file at /etc/init/elasticsearch.conf

description "elasticsearch service"

limit nofile 65536 65536

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

setuid elasticsearch
setgid elasticsearch

script
	#export ES_HEAP_SIZE=10g
	chdir {{ installdir }}

	exec bin/elasticsearch -Edefault.path.logs={{ logdir }} -Edefault.path.data={{ datadir }}
end script