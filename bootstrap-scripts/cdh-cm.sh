#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
cloudera:
  role: CM
roles:
  - cloudera_manager
  - platform_testing_cdh
  - mysql_connector
pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-cm
EOF

echo $PNDA_CLUSTER-cdh-cm > /etc/hostname
hostname $PNDA_CLUSTER-cdh-cm

service salt-minion restart
