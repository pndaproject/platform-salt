NAME=zookeeper
ZOOCFGDIR={{ install_dir }}/conf
ZOOLIBDIR={{ install_dir }}/lib

CLASSPATH="$ZOOCFGDIR:$ZOOLIBDIR/jline-0.9.94.jar:$ZOOLIBDIR/log4j-1.2.16.jar:$ZOOLIBDIR/netty-3.7.0.Final.jar:$ZOOLIBDIR/slf4j-api-1.6.1.jar:$ZOOLIBDIR/slf4j-log4j12-1.6.1.jar:/usr/share/java/zookeeper.jar"

ZOOCFG="$ZOOCFGDIR/zoo.cfg"
ZOO_LOG_DIR=/var/log/pnda/$NAME
USER=$NAME
GROUP=$NAME
PIDDIR=/var/run/$NAME
PIDFILE=$PIDDIR/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
JAVA=/usr/bin/java
ZOOMAIN="-Dcom.sun.management.jmxremote=true
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.port=9051
org.apache.zookeeper.server.quorum.QuorumPeerMain"
ZOO_LOG4J_PROP="WARN,ROLLINGFILE"
JMXLOCALONLY=false
JAVA_OPTS="-Xms{{ heap_size }} -Xmx{{ heap_size }}"
