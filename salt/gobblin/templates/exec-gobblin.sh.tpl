#!/bin/bash

function record_last_status {
  echo $1 > ${GOBBLIN_RUN_DIR}/_INGEST_RUN
}

function log_status {
  [[ $1 -eq 0 ]] && DESCR="OK"
  [[ $1 -ne 0 ]] && DESCR="ERROR"
  echo "$(date +%Y-%m-%dT%T%z) $1 ${DESCR}" >> $GOBBLIN_LOG_DIR/audit.log
}

./bin/gobblin-mapreduce.sh --conf $GOBBLIN_CONF_FILE --logdir $GOBBLIN_LOG_DIR --workdir $GOBBLIN_WORK_DIR --jars $GOBBLIN_JARS
STATUS=$?

record_last_status ${STATUS}
log_status ${STATUS}

exit ${STATUS}
