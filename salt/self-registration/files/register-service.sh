#!/bin/bash
# Register a service on this host with Consul
# Parameters:
#  $1 - service name
#  $2 - port
#  IP address is automatically determined with hostname -I | cut -f 1 -d ' '
export MY_IP=$(hostname -I | cut -f 1 -d ' ')
curl --request PUT --data "{\"ID\": \"$1\",\"Name\": \"$1\",\"Address\": \"${MY_IP}\",\"Port\": $2}"  http://${MY_IP}:8500/v1/agent/service/register
