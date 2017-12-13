hbase-rest:
  port: 20550
  info-port: 20551

hbase-thrift:
  port: 9090
  info-port: 9091

log-shipper-patterns:
  hadoop:
    - '"/var/log/pnda/hadoop/*/*.log"'
    - '"/var/log/pnda/hadoop/*/*.out"'
  hadoop-yarn:
    - '"/var/log/pnda/hadoop-yarn/*/*.log"'
    - '"/var/log/pnda/hadoop-yarn/*/*.out"'
  hbase:
    - '"/var/log/pnda/hbase/*.log"'
    - '"/var/log/pnda/hbase/*.out"'
  oozie:
    - '"/var/log/pnda/oozie/*.log"'
    - '"/var/log/pnda/oozie/*.out"'
