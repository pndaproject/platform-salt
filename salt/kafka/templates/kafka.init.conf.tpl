# Ubuntu upstart file at /etc/init/kafka.conf

description "kafka service"

limit nofile 32768 32768

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

setuid kafka
setgid kafka

pre-start script

end script

chdir {{ workdir }}

script
    export JMX_PORT=9050
    export KAFKA_HEAP_OPTS="-Xms{{ mem_xms}}g -Xmx{{ mem_xmx}}g -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35"
    bin/kafka-server-start.sh config/server.properties
end script
post-stop exec sleep 5
pre-start exec sleep 5
