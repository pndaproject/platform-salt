#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
roles:
  - kafka_manager
  - platform_testing_general
  - elk
  - zookeeper
  - kafka

pnda_cluster: $PNDA_CLUSTER
broker_id: 0
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-kafka
EOF

echo $PNDA_CLUSTER-kafka > /etc/hostname
hostname $PNDA_CLUSTER-kafka

service salt-minion restart
