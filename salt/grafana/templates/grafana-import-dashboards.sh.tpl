#!/bin/bash
set -e

[ "$#" -ne 1 ] && echo "Missing template filename" && exit 1

TEMP_FILE="$1.salt.tmp"
trap 'rm -f -- "${TEMP_FILE}"' INT TERM HUP EXIT

JSON_PREFIX='{ "inputs": [
  {
    "type": "datasource",
    "pluginId": "graphite",
    "name": "DS_PNDA_GRAPHITE",
    "value": "PNDA Graphite"
  }
 ],
 "dashboard": '
JSON_SUFFIX=', "overwrite": true }'

echo "${JSON_PREFIX}" > "${TEMP_FILE}"
cat "$1" >> "${TEMP_FILE}"
echo "${JSON_SUFFIX}" >> "${TEMP_FILE}"

curl -H "Content-Type: application/json" -X POST -d @"${TEMP_FILE}" http://{{ pnda_user }}:{{ pnda_password }}@localhost:3000/api/dashboards/import
