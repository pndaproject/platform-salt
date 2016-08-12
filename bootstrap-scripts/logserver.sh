#!/bin/bash -v

set -e

cat > /etc/salt/grains <<EOF
cloudera:
  cluster_flavour: $PNDA_FLAVOR
roles:
  - logserver
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-logserver
EOF

echo $PNDA_CLUSTER-logserver > /etc/hostname
hostname $PNDA_CLUSTER-logserver

service salt-minion restart
