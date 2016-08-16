DETAILS=$($1/bin/kafka-topics.sh --zookeeper $2 --describe --topic $3)
if [ -z "${DETAILS}" ]; then
  exit 1
else
  exit 0
fi
