#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
cloudera:
  role: EDGE
roles:
  - cloudera_edge_jupyter
  - jupyter
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-jupyter
EOF

echo $PNDA_CLUSTER-jupyter > /etc/hostname
hostname $PNDA_CLUSTER-jupyter

service salt-minion restart
