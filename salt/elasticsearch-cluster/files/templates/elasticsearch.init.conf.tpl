# Ubuntu upstart file at /etc/init/elasticsearch.conf

description "elasticsearch service"

limit nofile 32768 32768

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

setuid elasticsearch
setgid elasticsearch

pre-start script

end script
script
    export ES_HEAP_SIZE=10g
	chdir {{ installdir }}

	exec bin/elasticsearch -Ees.default.path.logs={{ logdir }} -Ees.default.path.data={{ datadir }} -Ees.default.path.work={{ workdir }} 
end script