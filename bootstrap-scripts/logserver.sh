#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
roles:
  - elk
  - logserver
  - kibana_dashboard
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-logserver
EOF

echo $PNDA_CLUSTER-logserver > /etc/hostname
hostname $PNDA_CLUSTER-logserver

service salt-minion restart
