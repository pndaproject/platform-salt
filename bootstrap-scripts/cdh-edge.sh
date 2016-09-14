#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: EDGE
roles:
  - cloudera_edge
  - console_frontend
  - console_backend
  - gobblin
  - deployment_manager
  - package_repository
  - data_service

pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-edge
EOF

echo $PNDA_CLUSTER-cdh-edge > /etc/hostname
hostname $PNDA_CLUSTER-cdh-edge

service salt-minion restart
