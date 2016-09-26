#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
roles:
  - bastion
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-bastion
EOF

echo $PNDA_CLUSTER-bastion > /etc/hostname
hostname $PNDA_CLUSTER-bastion

service salt-minion restart
