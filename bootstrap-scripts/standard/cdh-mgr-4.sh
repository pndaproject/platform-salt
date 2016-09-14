#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: MGR04
roles:
  - cloudera_management
  - cloudera_zookeeper
  - cloudera_oozie_database

pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-mgr-4
EOF

echo $PNDA_CLUSTER-cdh-mgr-4 > /etc/hostname
hostname $PNDA_CLUSTER-cdh-mgr-4

service salt-minion restart
