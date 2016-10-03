#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
roles:
  - zookeeper
  - kafka
EOF

if [ $1 = 0 ]; then
cat >> /etc/salt/grains <<EOF
  - platform_testing_general
  - kafka_manager
  - elk
EOF
fi

cat >> /etc/salt/grains <<EOF
pnda_cluster: $PNDA_CLUSTER
cluster: zk$PNDA_CLUSTER
broker_id: $1
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-kafka-$1
EOF

echo $PNDA_CLUSTER-kafka-$1 > /etc/hostname
hostname $PNDA_CLUSTER-kafka-$1

service salt-minion restart
