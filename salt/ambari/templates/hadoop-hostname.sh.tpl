#!/bin/sh
local_hostname=$(cat /etc/hostname)
echo ${local_hostname}.{{ pillar['consul']['node'] }}.{{ pillar['consul']['data_center'] }}.{{ pillar['consul']['domain'] }}