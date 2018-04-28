[Unit]
Description=Linked-in Gobblin MRv2 application: PNDA pull

[Service]
Type=oneshot
UMask=022
User=pnda
Environment="JAVA_HOME=/usr/lib/jvm/java-8-oracle/" "HADOOP_BIN_DIR={{ hadoop_home_bin }}" "GOBBLIN_CONF_FILE=/opt/pnda/gobblin/configs/mr.pull" "GOBBLIN_LOG_DIR=/var/log/pnda/gobblin" "GOBBLIN_WORK_DIR=/user/pnda/gobblin/work
" 'GOBBLIN_JARS=lib/*.jar' 'GOBBLIN_RUN_DIR=/opt/pnda/gobblin/run'
WorkingDirectory=/opt/pnda/gobblin/gobblin-dist
ExecStart=/usr/bin/bash ../run/exec-gobblin.sh
