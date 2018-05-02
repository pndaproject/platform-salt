#!/bin/bash
# $1 - host running oozie server
set -x
export ts=$(sudo -u hdfs hadoop fs -ls -C /user/oozie/share/lib/ | cut -d'_' -f2 | sort -r | head -n 1)
sudo -u hdfs hdfs dfs -rm -r -f -skipTrash /user/oozie/share/lib/lib_${ts}/spark2 || true
sudo -u hdfs hdfs dfs -mkdir /user/oozie/share/lib/lib_${ts}/spark2
sudo -u hdfs hdfs dfs -put /usr/hdp/current/spark2-client/jars/* /user/oozie/share/lib/lib_${ts}/spark2/
sudo -u hdfs hdfs dfs -put /usr/hdp/current/oozie-server/share/lib/spark/oozie-sharelib-spark-*.jar /user/oozie/share/lib/lib_${ts}/spark2/
sudo -u hdfs hdfs dfs -put /etc/hive/conf/hive-site.xml /user/oozie/share/lib/lib_${ts}/spark2/
sudo -u hdfs hdfs dfs -put /usr/hdp/current/spark2-client/python/lib/py* /user/oozie/share/lib/lib_${ts}/spark2/
# Work around for duplicate jars issue
sudo -u hdfs hdfs dfs -ls /user/oozie/share/lib/lib_${ts}/oozie |tr -s ' ' | cut -d' ' -f8  > /tmp/spark2list1
sudo -u hdfs -E bash -c 'for f in $(cat /tmp/spark2list1);do echo $f; hdfs dfs -rm -skipTrash /user/oozie/share/lib/lib_${ts}/spark2/${f##*/};done'
sudo -u hdfs hdfs dfs -ls /pnda/deployment/platform |tr -s ' ' | cut -d' ' -f8 > /tmp/spark2list2
sudo -u hdfs -E bash -c 'for f in $(cat /tmp/spark2list2);do echo $f; hdfs dfs -rm -skipTrash /user/oozie/share/lib/lib_${ts}/spark2/${f##*/};done'
# Work around for jackson conflicting versions issue
sudo -u hdfs hadoop fs -rm -r -f -skipTrash /user/oozie/share/lib/lib_${ts}/oozie/jackson*
sudo -u hdfs hadoop fs -mv /user/oozie/share/lib/lib_${ts}/spark2/jackson* /user/oozie/share/lib/lib_20180424152055/oozie/
sudo -u oozie oozie admin -oozie http://${1}:11000/oozie -sharelibupdate