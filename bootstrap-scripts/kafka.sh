#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
roles:
  - kafka
pnda_cluster: $PNDA_CLUSTER
broker_id: $1
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-kafka-$1
EOF

echo $PNDA_CLUSTER-kafka-$1 > /etc/hostname
hostname $PNDA_CLUSTER-kafka-$1

service salt-minion restart
