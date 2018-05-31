#!/bin/bash
# Register a service on this host with Consul
# Parameters:
#  $1 - service name
#  $2 - port
#  IP address is automatically determined with hostname --ip-address
curl --request PUT --data "{\"ID\": \"$1\",\"Name\": \"$1\",\"Address\": \"$(hostname --ip-address)\",\"Port\": $2}"  http://$(hostname --ip-address):8500/v1/agent/service/register
