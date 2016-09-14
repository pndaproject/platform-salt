#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: MGR02
roles:
  - cloudera_management
  - cloudera_namenode
  - cloudera_zookeeper

pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-mgr-2
EOF

echo $PNDA_CLUSTER-cdh-mgr-2 > /etc/hostname
hostname $PNDA_CLUSTER-cdh-mgr-2

service salt-minion restart
