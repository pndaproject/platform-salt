#!/bin/bash
nodeenv --without-ssl --prebuilt env
. env/bin/activate
npm install -g elasticdump
elasticdump --input=/home/kibana/kibana.json --output=http://localhost:9200/.kibana
deactivate_node
