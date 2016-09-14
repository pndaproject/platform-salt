#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: CM
roles:
  - cloudera_management
  - cloudera_manager
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-cm
EOF

echo $PNDA_CLUSTER-cdh-cm > /etc/hostname
hostname $PNDA_CLUSTER-cdh-cm

service salt-minion restart
