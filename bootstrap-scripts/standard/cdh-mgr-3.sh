#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
cloudera:
  role: MGR03
roles:
  - mysql_connector
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-mgr-3
EOF

echo $PNDA_CLUSTER-cdh-mgr-3 > /etc/hostname
hostname $PNDA_CLUSTER-cdh-mgr-3

service salt-minion restart
