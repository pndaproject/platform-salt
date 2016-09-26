#!/bin/bash -v

set -e

cat >> /etc/salt/grains <<EOF
cloudera:
  role: EDGE
roles:
  - cloudera_edge
  - console_frontend
  - console_backend_data_logger
  - console_backend_data_manager
  - graphite
  - gobblin
  - deployment_manager
  - package_repository
  - data_service
  - impala-shell
  - yarn-gateway
  - hbase_opentsdb_tables
  - hdfs_cleaner
  - master_dataset

pnda_cluster: $PNDA_CLUSTER
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-cdh-edge
EOF

echo $PNDA_CLUSTER-cdh-edge > /etc/hostname
hostname $PNDA_CLUSTER-cdh-edge

service salt-minion restart
