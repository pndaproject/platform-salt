export JMX_PORT=9050
export KAFKA_HEAP_OPTS="-Xms{{ mem_xms}}g -Xmx{{ mem_xmx}}g -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35"
