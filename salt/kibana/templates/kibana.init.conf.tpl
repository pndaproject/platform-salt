# Ubuntu upstart file at /etc/init/kibana.conf

description "kibana service"

limit nofile 32768 32768

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

setuid kibana
setgid kibana

pre-start script

end script

chdir {{ installdir }}

exec bin/kibana
