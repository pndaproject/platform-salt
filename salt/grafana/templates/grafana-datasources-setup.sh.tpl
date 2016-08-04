#!/bin/bash
set -e

while ! nc -z localhost 3000; do
  sleep 1
done
sleep 1

OPENTSDB_DATASOURCE='{ "name": "PNDA OpenTSDB", "type": "opentsdb", "url": "http://localhost:4242", "access": "proxy", "basicAuth": false, "isDefault": true }'

curl -H "Content-Type: application/json" -X POST -d "${OPENTSDB_DATASOURCE}" http://{{ pnda_user }}:{{ pnda_password }}@localhost:3000/api/datasources
