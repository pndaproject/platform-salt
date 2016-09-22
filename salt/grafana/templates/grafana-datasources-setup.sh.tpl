#!/bin/bash
set -e

while ! nc -z localhost 3000; do
  sleep 1
done
sleep 1

OPENTSDB_DATASOURCE='{ "name": "PNDA OpenTSDB", "type": "opentsdb", "url": "http://localhost:4242", "access": "proxy", "basicAuth": false, "isDefault": true }'
PNDA_GRAPHITE_DATASOURCE='{ "name": "PNDA Graphite", "type": "graphite", "url": "http://{{ pnda_graphite_host }}:{{ pnda_graphite_port }}", "access": "proxy", "basicAuth": false, "isDefault": false }'

curl -H "Content-Type: application/json" -X POST -d "${OPENTSDB_DATASOURCE}" http://{{ pnda_user }}:{{ pnda_password }}@localhost:3000/api/datasources
curl -H "Content-Type: application/json" -X POST -d "${PNDA_GRAPHITE_DATASOURCE}" http://{{ pnda_user }}:{{ pnda_password }}@localhost:3000/api/datasources
