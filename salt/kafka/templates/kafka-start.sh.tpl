#!/bin/bash

. /etc/default/kafka-env
{{ workdir }}/bin/kafka-server-start.sh {{ workdir }}/config/server.properties
