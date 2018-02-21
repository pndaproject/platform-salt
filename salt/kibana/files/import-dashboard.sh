#!/bin/bash

k_result=1
num_tries=30
while [ $k_result -ne 0 ] && [ $num_tries -gt 0 ]
do
  echo "Checking kibana connectivity ($num_tries remaining)..."
  curl -f 'localhost:5601'
  k_result=$?
  if [ $k_result -ne 0 ]; then
    sleep 5
    num_tries=$(($num_tries-1))
  fi
done

curl -X POST -H "Content-Type: application/json" -H "kbn-xsrf: true" -d @dashboard.json http://localhost:5601/api/kibana/dashboards/import