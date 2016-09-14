#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: MGR01
roles:
  - cloudera_management
  - cloudera_oozie_database
  - cloudera_namenode
  - cloudera_zookeeper

pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-mgr-1
EOF

echo $PNDA_CLUSTER-cdh-mgr-1 > /etc/hostname
hostname $PNDA_CLUSTER-cdh-mgr-1

service salt-minion restart
