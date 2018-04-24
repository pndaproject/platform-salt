#!/bin/bash
# $1 - host running oozie server
set -x
export ts=$(sudo -u hdfs hadoop fs -ls -C /user/oozie/share/lib/ | cut -d'_' -f2 | sort -r | head -n 1)
sudo -u hdfs hdfs dfs -rm -r -f -skipTrash /user/oozie/share/lib/lib_${ts}/spark2 || true
sudo -u oozie oozie admin -oozie http://${1}:11000/oozie -sharelibupdate