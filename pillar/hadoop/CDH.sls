log-shipper-patterns:
  hadoop:
    - '"/var/log/pnda/hadoop/*/*.log"'
    - '"/var/log/pnda/hadoop/*/*.log.out"'
  hadoop-yarn:
    - '"/var/log/pnda/hadoop-yarn/*.log.out"'
  hbase:
    - '"/var/log/pnda/hbase/*.log.out"'
  oozie:
    - '"/var/log/pnda/oozie/*.log"'
    - '"/var/log/pnda/oozie/*.log.out"'
  impala:
    - '"/var/log/pnda/impala/*.ERROR"'
    - '"/var/log/pnda/impala/*.WARNING"'
    - '"/var/log/pnda/impala/*.INFO"'
    - '"/var/log/pnda/impala-llama/*.log"'
  hue:
    - '"/var/log/pnda/hue/*.log"'