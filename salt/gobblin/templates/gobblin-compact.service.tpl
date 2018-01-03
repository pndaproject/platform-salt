[Unit]
Description=Linked-in Gobblin MRv2 application: PNDA pull

[Service]
Type=oneshot
UMask=022
User=pnda
Environment="JAVA_HOME=/usr/lib/jvm/java-8-oracle/" "HADOOP_BIN_DIR={{ hadoop_home_bin }}" "GOBBLIN_CONF_FILE=/opt/pnda/gobblin/configs/mr.compact" "GOBBLIN_LOG_DIR=/var/log/pnda/gobblin" "GOBBLIN_WORK_DIR=/user/pnda/gobblin/work" 'GOBBLIN_JARS=lib/*.jar'
WorkingDirectory=/opt/pnda/gobblin/gobblin-dist
ExecStart=/usr/bin/bash ./bin/gobblin-compaction.sh --type mr --conf $GOBBLIN_CONF_FILE --logdir $GOBBLIN_LOG_DIR --workdir $GOBBLIN_WORK_DIR --jars $GOBBLIN_JARS
