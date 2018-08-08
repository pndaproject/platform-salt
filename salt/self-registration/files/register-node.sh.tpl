#!/bin/bash
# Register a service on this host with Consul
# Parameters:
#  $1 - service name
#  $2 - port
#  IP address is automatically determined with hostname --ip-address
export MY_IP=$(hostname --ip-address)
curl \
  --request PUT \
  --data "{\"Node\": \"$(hostname)\",\"Address\": \"$MY_IP\", \"Datacenter\":\"{{ consul_datacenter }}\", \"TaggedAddresses\":{\"lan\":\"$MY_IP\",\"wan\":\"$MY_IP\"}}" \
        http://$MY_IP:8500/v1/catalog/register
