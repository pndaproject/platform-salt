#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: DATANODE
roles:
  - cloudera_datanode
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-dn-$1
EOF

echo $PNDA_CLUSTER-cdh-dn-$1 > /etc/hostname
hostname $PNDA_CLUSTER-cdh-dn-$1

service salt-minion restart
