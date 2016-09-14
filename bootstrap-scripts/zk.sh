#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
roles:
  - zookeeper
pnda_cluster: $PNDA_CLUSTER
cluster: zk$PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-zk-$1
EOF

echo $PNDA_CLUSTER-zk-$1 > /etc/hostname
hostname $PNDA_CLUSTER-zk-$1

service salt-minion restart
