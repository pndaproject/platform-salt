#!/bin/bash

set -ex

[ -r "/usr/share/java/zookeeper.jar" ] || exit 0
[ -r "{{ conf_dir }}/environment" ] || exit 0
. {{ conf_dir }}/environment
[ -d $ZOO_LOG_DIR ] || mkdir -p $ZOO_LOG_DIR
chown $USER:$GROUP $ZOO_LOG_DIR
