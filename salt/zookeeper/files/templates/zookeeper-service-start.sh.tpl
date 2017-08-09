#!/bin/bash

set -ex

. {{ conf_dir }}/environment
[ -r /etc/default/zookeeper ] && . /etc/default/zookeeper

if [ -z "$JMXDISABLE" ]; then
  JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=$JMXLOCALONLY"
fi

$JAVA -cp $CLASSPATH $JAVA_OPTS -Dzookeeper.log.dir=${ZOO_LOG_DIR} \
  	-Dzookeeper.root.logger=${ZOO_LOG4J_PROP} $ZOOMAIN $ZOOCFG
