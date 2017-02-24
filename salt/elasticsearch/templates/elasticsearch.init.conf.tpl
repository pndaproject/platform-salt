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

chdir {{ installdir }}

exec bin/elasticsearch -Des.default.config={{ defaultconfig }} -Des.default.path.logs={{ logdir }} -Des.default.path.data={{ datadir }} -Des.default.path.work={{ workdir }} -Des.default.path.conf={{ confdir }}