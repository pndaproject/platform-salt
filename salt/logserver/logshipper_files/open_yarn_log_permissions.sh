#!/bin/bash
for ((i=0;i<11;i++));
do
   setfacl -Rm u:logger:rx /var/log/pnda/hadoop-yarn/container
   sleep 5
done