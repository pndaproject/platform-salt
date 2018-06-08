"""
Name:       cfg_pico
Purpose:    Configuration for this particular flavor of PNDA

Author:     PNDA team

Created:    19/06/2017
"""

BLUEPRINT = r'''{
    "configurations": [
        {
            "ams-env" : {
                "properties_attributes" : { },
                "properties" : {
                    "timeline.metrics.skip.disk.metrics.patterns" : "true",
                    "ambari_metrics_user" : "ams",
                    "metrics_monitor_log_dir" : "/var/log/pnda/ambari-metrics-monitor",
                    "metrics_collector_heapsize" : "512",
                    "failover_strategy_blacklisted_interval" : "300",
                    "metrics_collector_pid_dir" : "/var/run/ambari-metrics-collector",
                    "metrics_collector_log_dir" : "/var/log/pnda/ambari-metrics-collector",
                    "metrics_monitor_pid_dir" : "/var/run/ambari-metrics-monitor",
{% raw %}
                    "content" : "\n# Set environment variables here.\n\n# AMS instance name\nexport AMS_INSTANCE_NAME={{hostname}}\n\n# The java implementation to use. Java 1.6 required.\nexport JAVA_HOME={{java64_home}}\n\n# Collector Log directory for log4j\nexport AMS_COLLECTOR_LOG_DIR={{ams_collector_log_dir}}\n\n# Monitor Log directory for outfile\nexport AMS_MONITOR_LOG_DIR={{ams_monitor_log_dir}}\n\n# Collector pid directory\nexport AMS_COLLECTOR_PID_DIR={{ams_collector_pid_dir}}\n\n# Monitor pid directory\nexport AMS_MONITOR_PID_DIR={{ams_monitor_pid_dir}}\n\n# AMS HBase pid directory\nexport AMS_HBASE_PID_DIR={{hbase_pid_dir}}\n\n# AMS Collector heapsize\nexport AMS_COLLECTOR_HEAPSIZE={{metrics_collector_heapsize}}\n\n# HBase Tables Initialization check enabled\nexport AMS_HBASE_INIT_CHECK_ENABLED={{ams_hbase_init_check_enabled}}\n\n# AMS Collector options\nexport AMS_COLLECTOR_OPTS=\"-Djava.library.path=/usr/lib/ams-hbase/lib/hadoop-native\"\n{%% if security_enabled %%}\nexport AMS_COLLECTOR_OPTS=\"$AMS_COLLECTOR_OPTS -Djava.security.auth.login.config={{ams_collector_jaas_config_file}}\"\n{%% endif %%}\n\n# AMS Collector GC options\nexport AMS_COLLECTOR_GC_OPTS=\"-XX:+UseConcMarkSweepGC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:{{ams_collector_log_dir}}/collector-gc.log-`date +'%%Y%%m%%d%%H%%M'`\"\nexport AMS_COLLECTOR_OPTS=\"$AMS_COLLECTOR_OPTS $AMS_COLLECTOR_GC_OPTS\"\n\n# Metrics collector host will be blacklisted for specified number of seconds if metric monitor failed to connect to it.\nexport AMS_FAILOVER_STRATEGY_BLACKLISTED_INTERVAL={{failover_strategy_blacklisted_interval}}"
{% endraw %}
                }
            }
        },
        {
            "ams-log4j" : {
                "properties_attributes" : { },
                "properties" : {
                    "ams_log_number_of_backup_files" : "2",
                    "ams_log_max_backup_size" : "100",
{% raw %}
                    "content" : "\n#\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n#\n\n# Define some default values that can be overridden by system properties\nams.log.dir=.\nams.log.file=ambari-metrics-collector.log\n\n# Root logger option\nlog4j.rootLogger=INFO,file\n\n# Direct log messages to a log file\nlog4j.appender.file=org.apache.log4j.RollingFileAppender\nlog4j.appender.file.File=${ams.log.dir}/${ams.log.file}\nlog4j.appender.file.MaxFileSize={{ams_log_max_backup_size}}MB\nlog4j.appender.file.MaxBackupIndex={{ams_log_number_of_backup_files}}\nlog4j.appender.file.layout=org.apache.log4j.PatternLayout\nlog4j.appender.file.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n"
{% endraw %}
                }
            }
        },
        {
            "ams-hbase-log4j" : {
            "properties_attributes" : { },
            "properties" : {
                "ams_hbase_log_maxfilesize" : "100",
                "ams_hbase_log_maxbackupindex" : "2",
                "ams_hbase_security_log_maxbackupindex" : "2",
                "ams_hbase_security_log_maxfilesize" : "100",
{% raw %}
                "content" : "\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\n\n# Define some default values that can be overridden by system properties\nhbase.root.logger=INFO,console\nhbase.security.logger=INFO,console\nhbase.log.dir=.\nhbase.log.file=hbase.log\n\n# Define the root logger to the system property \"hbase.root.logger\".\nlog4j.rootLogger=${hbase.root.logger}\n\n# Logging Threshold\nlog4j.threshold=ALL\n\n#\n# Daily Rolling File Appender\n#\nlog4j.appender.DRFA=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.DRFA.File=${hbase.log.dir}/${hbase.log.file}\n\n# Rollver at midnight\nlog4j.appender.DRFA.DatePattern=.yyyy-MM-dd\n\n# 30-day backup\nlog4j.appender.DRFA.MaxBackupIndex={{ams_hbase_log_maxbackupindex}}\nlog4j.appender.DRFA.layout=org.apache.log4j.PatternLayout\n\n# Pattern format: Date LogLevel LoggerName LogMessage\nlog4j.appender.DRFA.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t] %%c{2}: %%m%%n\n\n# Rolling File Appender properties\nhbase.log.maxfilesize={{ams_hbase_log_maxfilesize}}MB\nhbase.log.maxbackupindex={{ams_hbase_log_maxbackupindex}}\n\n# Rolling File Appender\nlog4j.appender.RFA=org.apache.log4j.RollingFileAppender\nlog4j.appender.RFA.File=${hbase.log.dir}/${hbase.log.file}\n\nlog4j.appender.RFA.MaxFileSize=${hbase.log.maxfilesize}\nlog4j.appender.RFA.MaxBackupIndex=${hbase.log.maxbackupindex}\n\nlog4j.appender.RFA.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RFA.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t] %%c{2}: %%m%%n\n\n#\n# Security audit appender\n#\nhbase.security.log.file=SecurityAuth.audit\nhbase.security.log.maxfilesize={{ams_hbase_security_log_maxfilesize}}MB\nhbase.security.log.maxbackupindex={{ams_hbase_security_log_maxbackupindex}}\nlog4j.appender.RFAS=org.apache.log4j.RollingFileAppender\nlog4j.appender.RFAS.File=${hbase.log.dir}/${hbase.security.log.file}\nlog4j.appender.RFAS.MaxFileSize=${hbase.security.log.maxfilesize}\nlog4j.appender.RFAS.MaxBackupIndex=${hbase.security.log.maxbackupindex}\nlog4j.appender.RFAS.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RFAS.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\nlog4j.category.SecurityLogger=${hbase.security.logger}\nlog4j.additivity.SecurityLogger=false\n#log4j.logger.SecurityLogger.org.apache.hadoop.hbase.security.access.AccessController=TRACE\n\n#\n# Null Appender\n#\nlog4j.appender.NullAppender=org.apache.log4j.varia.NullAppender\n\n#\n# console\n# Add \"console\" to rootlogger above if you want to use this\n#\nlog4j.appender.console=org.apache.log4j.ConsoleAppender\nlog4j.appender.console.target=System.err\nlog4j.appender.console.layout=org.apache.log4j.PatternLayout\nlog4j.appender.console.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t] %%c{2}: %%m%%n\n\n# Custom Logging levels\n\nlog4j.logger.org.apache.zookeeper=INFO\n#log4j.logger.org.apache.hadoop.fs.FSNamesystem=DEBUG\nlog4j.logger.org.apache.hadoop.hbase=INFO\n# Make these two classes INFO-level. Make them DEBUG to see more zk debug.\nlog4j.logger.org.apache.hadoop.hbase.zookeeper.ZKUtil=INFO\nlog4j.logger.org.apache.hadoop.hbase.zookeeper.ZooKeeperWatcher=INFO\n#log4j.logger.org.apache.hadoop.dfs=DEBUG\n# Set this class to log INFO only otherwise its OTT\n# Enable this to get detailed connection error/retry logging.\n# log4j.logger.org.apache.hadoop.hbase.client.HConnectionManager$HConnectionImplementation=TRACE\n\n\n# Uncomment this line to enable tracing on _every_ RPC call (this can be a lot of output)\n#log4j.logger.org.apache.hadoop.ipc.HBaseServer.trace=DEBUG\n\n# Uncomment the below if you want to remove logging of client region caching'\n# and scan of .META. messages\n# log4j.logger.org.apache.hadoop.hbase.client.HConnectionManager$HConnectionImplementation=INFO\n# log4j.logger.org.apache.hadoop.hbase.client.MetaScanner=INFO"
{% endraw %}
                }
            }
        },
        {
            "ams-site" : {
                "properties_attributes" : { },
                "properties" : {
                    "timeline.metrics.cluster.aggregator.hourly.interval" : "3600",
                    "timeline.metrics.cluster.aggregator.minute.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.cluster.aggregator.daily.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.host.aggregator.hourly.interval" : "3600",
                    "timeline.metrics.aggregators.skip.blockcache.enabled" : "false",
                    "timeline.metrics.service.rpc.address" : "0.0.0.0:60200",
                    "timeline.metrics.service.operation.mode" : "distributed",
                    "timeline.metrics.aggregator.checkpoint.dir" : "/var/lib/ambari-metrics-collector/checkpoint",
                    "failover.strategy" : "round-robin",
                    "timeline.metrics.cluster.aggregator.second.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.service.http.policy" : "HTTP_ONLY",
                    "timeline.metrics.downsampler.topn.value" : "10",
                    "timeline.metrics.host.aggregator.minute.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.service.watcher.timeout" : "30",
                    "timeline.metrics.service.checkpointDelay" : "60",
                    "timeline.metrics.cluster.aggregator.second.interval" : "120",
                    "timeline.metrics.service.webapp.address" : "0.0.0.0:6188",
                    "timeline.metrics.host.aggregator.daily.ttl" : "31536000",
                    "timeline.metrics.service.watcher.delay" : "30",
                    "timeline.metrics.service.watcher.disabled" : "true",
                    "timeline.metrics.hbase.init.check.enabled" : "true",
                    "timeline.metrics.host.aggregator.hourly.disabled" : "false",
                    "timeline.metrics.service.cluster.aggregator.appIds" : "datanode,nodemanager,hbase",
                    "timeline.metrics.cluster.aggregator.hourly.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.host.aggregator.daily.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.service.resultset.fetchSize" : "2000",
                    "timeline.metrics.cluster.aggregator.hourly.ttl" : "31536000",
                    "cluster.zookeeper.quorum" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "timeline.metrics.downsampler.topn.function" : "max",
                    "timeline.metrics.host.aggregator.ttl" : "86400",
                    "phoenix.spool.directory" : "/tmp",
                    "timeline.metrics.host.aggregate.splitpoints" : "master.FileSystem.HlogSplitTime_75th_percentile",
                    "timeline.metrics.service.handler.thread.count" : "20",
                    "timeline.metrics.cache.size" : "200",
                    "timeline.metrics.cluster.aggregator.minute.interval" : "300",
                    "timeline.metrics.cluster.aggregator.minute.ttl" : "2592000",
                    "timeline.metrics.host.aggregator.minute.interval" : "300",
                    "timeline.metrics.cluster.aggregator.interpolation.enabled" : "true",
                    "timeline.metrics.cache.commit.interval" : "10",
                    "timeline.metrics.host.aggregator.minute.disabled" : "false",
                    "timeline.metrics.service.metadata.filters" : "ContainerResource",
                    "timeline.metrics.cache.enabled" : "true",
                    "timeline.metrics.cluster.aggregate.splitpoints" : "master.FileSystem.HlogSplitTime_75th_percentile",
                    "timeline.metrics.cluster.aggregator.minute.disabled" : "false",
                    "timeline.metrics.service.use.groupBy.aggregators" : "true",
                    "phoenix.query.maxGlobalMemoryPercentage" : "25",
                    "timeline.metrics.service.default.result.limit" : "15840",
                    "timeline.metrics.hbase.compression.scheme" : "SNAPPY",
                    "timeline.metrics.cluster.aggregator.daily.ttl" : "63072000",
                    "cluster.zookeeper.property.clientPort" : "2181",
                    "timeline.metrics.sink.report.interval" : "60",
                    "timeline.metrics.cluster.aggregator.second.timeslice.interval" : "30",
                    "timeline.metrics.cluster.aggregation.sql.filters" : "sdisk\\_%%,boottime",
                    "timeline.metrics.downsampler.topn.metric.patterns" : "dfs.NNTopUserOpCounts.windowMs=60000.op=__%%.user=%%,dfs.NNTopUserOpCounts.windowMs=300000.op=__%%.user=%%,dfs.NNTopUserOpCounts.windowMs=1500000.op=__%%.user=%%",
                    "timeline.metrics.host.aggregator.hourly.ttl" : "2592000",
                    "timeline.metrics.cluster.aggregator.daily.interval" : "86400",
                    "timeline.metrics.host.aggregator.daily.disabled" : "false",
                    "timeline.metrics.cluster.aggregator.daily.disabled" : "false",
                    "timeline.metrics.cluster.aggregator.hourly.disabled" : "false",
                    "timeline.metrics.service.watcher.initial.delay" : "600",
                    "timeline.metrics.host.aggregator.minute.ttl" : "604800",
                    "timeline.metrics.hbase.data.block.encoding" : "FAST_DIFF",
                    "timeline.metrics.cluster.aggregator.second.disabled" : "false",
                    "timeline.metrics.sink.collection.period" : "10",
                    "timeline.metrics.host.aggregator.hourly.checkpointCutOffMultiplier" : "2",
                    "timeline.metrics.daily.aggregator.minute.interval" : "86400",
                    "timeline.metrics.cluster.aggregator.second.ttl" : "259200"
                }
            }
        },
        {
            "ams-grafana-env" : {
                "properties" : {
                    "metrics_grafana_log_dir" : "/var/log/pnda/ambari-metrics-grafana"
                }
            }
        },
        {
            "ams-hbase-env" : {
                "properties" : {
                    "hbase_log_dir" : "/var/log/pnda/ambari-metrics-collector"
                }
            }
        },
        {
            "spark-env" : {
                "properties" : {
                    "spark_pid_dir" : "/var/run/spark",
                    "spark_daemon_memory" : "1024",
                    "spark_log_dir" : "/var/log/pnda/spark",
                    "content" : "\n#!/usr/bin/env bash\n\n# This file is sourced when running various Spark programs.\n# Copy it as spark-env.sh and edit that to configure Spark for your site.\n\n# Options read in YARN client mode\n#SPARK_EXECUTOR_INSTANCES=\"2\" #Number of workers to start (Default: 2)\nSPARK_EXECUTOR_CORES=\"1\" #Number of cores for the workers (Default: 1).\nSPARK_EXECUTOR_MEMORY=\"512M\" #Memory per Worker (e.g. 1000M, 2G) (Default: 1G)\nSPARK_DRIVER_MEMORY=\"512M\" #Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)\n#SPARK_YARN_APP_NAME=\"spark\" #The name of your application (Default: Spark)\n#SPARK_YARN_QUEUE=\"~@~Xdefault~@~Y\" #The hadoop queue to use for allocation requests (Default: @~Xdefault~@~Y)\n#SPARK_YARN_DIST_FILES=\"\" #Comma separated list of files to be distributed with the job.\n#SPARK_YARN_DIST_ARCHIVES=\"\" #Comma separated list of archives to be distributed with the job.\n\n# Generic options for the daemons used in the standalone deploy mode\n\n# Alternate conf dir. (Default: ${SPARK_HOME}/conf)\nexport SPARK_CONF_DIR=${SPARK_CONF_DIR:-{{ '{{' }}spark_home{{ '}}' }}/conf}\n\n# Where log files are stored.(Default:${SPARK_HOME}/logs)\n#export SPARK_LOG_DIR=${SPARK_HOME:-{{ '{{' }}spark_home{{ '}}' }}}/logs\nexport SPARK_LOG_DIR={{ '{{' }}spark_log_dir{{ '}}' }}\n\n# Where the pid file is stored. (Default: /tmp)\nexport SPARK_PID_DIR={{ '{{' }}spark_pid_dir{{ '}}' }}\n\n# A string representing this instance of spark.(Default: $USER)\nSPARK_IDENT_STRING=$USER\n\n# The scheduling priority for daemons. (Default: 0)\nSPARK_NICENESS=0\n\nexport HADOOP_HOME=${HADOOP_HOME:-{{ '{{' }}hadoop_home{{ '}}' }}}\nexport HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-{{ '{{' }}hadoop_conf_dir{{ '}}' }}}\n\n# The java implementation to use.\nexport JAVA_HOME={{ '{{' }}java_home{{ '}}' }}\n\n#Memory for Master, Worker and history server (default: 1024MB)\nexport SPARK_DAEMON_MEMORY={{ '{{' }}spark_daemon_memory{{ '}}' }}m\n\nif [ -d \"/etc/tez/conf/\" ]; then\n  export TEZ_CONF_DIR=/etc/tez/conf\nelse\n  export TEZ_CONF_DIR=\nfi\nexport PYSPARK_PYTHON=/opt/pnda/anaconda/bin/python\nexport PYTHONPATH={{ app_packages_dir }}/lib/python2.7/site-packages:$PYTHONPATH\n#"
                }
            }
        },
        {
            "spark-metrics-properties" : {
                "properties" : {
                    "content" : "*.sink.graphite.class=org.apache.spark.metrics.sink.GraphiteSink\n*.sink.graphite.host={{ pnda_graphite_host }}\n*.sink.graphite.port=2003\n*.sink.graphite.period=60\n*.sink.graphite.prefix=spark\n*.sink.graphite.unit=seconds\n# Enable jvm source for instance master, worker, driver and executor\nmaster.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nworker.source.jvm.class=org.apache.spark.metrics.source.JvmSource\ndriver.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nexecutor.source.jvm.class=org.apache.spark.metrics.source.JvmSource"
                }
            }
        },
        {
            "spark2-env" : {
                "properties_attributes" : { },
                "properties" : {
                    "spark_user" : "spark",
                    "spark_group" : "spark",
                    "spark_pid_dir" : "/var/run/spark2",
                    "spark_thrift_cmd_opts" : "",
                    "spark_daemon_memory" : "1024",
                    "spark_log_dir" : "/var/log/pnda/spark2",
                    "content" : "\n#!/usr/bin/env bash\n\n# This file is sourced when running various Spark programs.\n# Copy it as spark-env.sh and edit that to configure Spark for your site.\n\n# Options read in YARN client mode\n#SPARK_EXECUTOR_INSTANCES=\"2\" #Number of workers to start (Default: 2)\n#SPARK_EXECUTOR_CORES=\"1\" #Number of cores for the workers (Default: 1).\n#SPARK_EXECUTOR_MEMORY=\"1G\" #Memory per Worker (e.g. 1000M, 2G) (Default: 1G)\n#SPARK_DRIVER_MEMORY=\"512M\" #Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)\n#SPARK_YARN_APP_NAME=\"spark\" #The name of your application (Default: Spark)\n#SPARK_YARN_QUEUE=\"default\" #The hadoop queue to use for allocation requests (Default: default)\n#SPARK_YARN_DIST_FILES=\"\" #Comma separated list of files to be distributed with the job.\n#SPARK_YARN_DIST_ARCHIVES=\"\" #Comma separated list of archives to be distributed with the job.\n\n# Generic options for the daemons used in the standalone deploy mode\n\n# Alternate conf dir. (Default: ${SPARK_HOME}/conf)\nexport SPARK_CONF_DIR=${SPARK_CONF_DIR:-{{ '{{' }}spark_home{{ '}}' }}/conf}\n\n# Where log files are stored.(Default:${SPARK_HOME}/logs)\n#export SPARK_LOG_DIR=${SPARK_HOME:-{{ '{{' }}spark_home{{ '}}' }}}/logs\nexport SPARK_LOG_DIR={{ '{{' }}spark_log_dir{{ '}}' }}\n\n# Where the pid file is stored. (Default: /tmp)\nexport SPARK_PID_DIR={{ '{{' }}spark_pid_dir{{ '}}' }}\n\n#Memory for Master, Worker and history server (default: 1024MB)\nexport SPARK_DAEMON_MEMORY={{ '{{' }}spark_daemon_memory{{ '}}' }}m\n\n# A string representing this instance of spark.(Default: $USER)\nSPARK_IDENT_STRING=$USER\n\n# The scheduling priority for daemons. (Default: 0)\nSPARK_NICENESS=0\n\nexport HADOOP_HOME=${HADOOP_HOME:-{{ '{{' }}hadoop_home{{ '}}' }}}\nexport HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-{{ '{{' }}hadoop_conf_dir{{ '}}' }}}\n\n# The java implementation to use.\nexport JAVA_HOME={{ '{{' }}java_home{{ '}}' }}\nexport PYSPARK_PYTHON=/opt/pnda/anaconda/bin/python\nexport PYTHONPATH={{ app_packages_dir }}/lib/python2.7/site-packages:$PYTHONPATH\n#"
                }
            }
        },
        {
            "yarn-env" : {
                "properties" : {
                    "yarn_log_dir_prefix" : "/var/log/pnda/hadoop-yarn",
                    "resourcemanager_heapsize" : "1024"
                }
            }
        },
        {
            "yarn-site" : {
                "properties" : {
                    "yarn.nodemanager.log-dirs" : "/var/log/pnda/hadoop-yarn/container",
                    "yarn.nodemanager.local-dirs" : "/mnt/hadoop/yarn/nm",
                    "yarn.nodemanager.localizer.cache.target-size-mb" : "1024",
                    "yarn.nodemanager.resource.cpu-vcores" : "8",
                    "yarn.nodemanager.resource.memory-mb" : "4096",
                    "yarn.log-aggregation-enable" : "false",
                    "yarn.log-aggregation.retain-seconds" : "7200",
                    "yarn.scheduler.minimum-allocation-vcores" : "1",
                    "yarn.scheduler.minimum-allocation-mb" : "256",
                    "yarn.scheduler.maximum-allocation-mb" : "4096",
                    "yarn.scheduler.maximum-allocation-vcores" : "8",
                    "yarn.acl.enable" : "true",
                    "yarn.timeline-service.leveldb-timeline-store.path" : "/mnt/hadoop/yarn/timeline"
                }
            }
        },
        {
            "yarn-log4j" : {
                "properties_attributes" : { },
                "properties" : {
                    "yarn_rm_summary_log_max_backup_size" : "100",
                    "yarn_rm_summary_log_number_of_backup_files" : "2",
{% raw %}
                    "content" : "\n#Relative to Yarn Log Dir Prefix\nyarn.log.dir=.\n#\n# Job Summary Appender\n#\n# Use following logger to send summary to separate file defined by\n# hadoop.mapreduce.jobsummary.log.file rolled daily:\n# hadoop.mapreduce.jobsummary.logger=INFO,JSA\n#\nhadoop.mapreduce.jobsummary.logger=${hadoop.root.logger}\nhadoop.mapreduce.jobsummary.log.file=hadoop-mapreduce.jobsummary.log\nlog4j.appender.JSA=org.apache.log4j.RollingFileAppender\n# Set the ResourceManager summary log filename\nyarn.server.resourcemanager.appsummary.log.file=hadoop-mapreduce.jobsummary.log\n# Set the ResourceManager summary log level and appender\nyarn.server.resourcemanager.appsummary.logger=${hadoop.root.logger}\n#yarn.server.resourcemanager.appsummary.logger=INFO,RMSUMMARY\n\n# To enable AppSummaryLogging for the RM,\n# set yarn.server.resourcemanager.appsummary.logger to\n# LEVEL,RMSUMMARY in hadoop-env.sh\n\n# Appender for ResourceManager Application Summary Log\n# Requires the following properties to be set\n#    - hadoop.log.dir (Hadoop Log directory)\n#    - yarn.server.resourcemanager.appsummary.log.file (resource manager app summary log filename)\n#    - yarn.server.resourcemanager.appsummary.logger (resource manager app summary log level and appender)\nlog4j.appender.RMSUMMARY=org.apache.log4j.RollingFileAppender\nlog4j.appender.RMSUMMARY.File=${yarn.log.dir}/${yarn.server.resourcemanager.appsummary.log.file}\nlog4j.appender.RMSUMMARY.MaxFileSize={{yarn_rm_summary_log_max_backup_size}}MB\nlog4j.appender.RMSUMMARY.MaxBackupIndex={{yarn_rm_summary_log_number_of_backup_files}}\nlog4j.appender.RMSUMMARY.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RMSUMMARY.layout.ConversionPattern=%%d{ISO8601} %%p %%c{2}: %%m%%n\nlog4j.appender.JSA.layout=org.apache.log4j.PatternLayout\nlog4j.appender.JSA.layout.ConversionPattern=%%d{yy/MM/dd HH:mm:ss} %%p %%c{2}: %%m%%n\nlog4j.appender.JSA.MaxBackupIndex={{yarn_rm_summary_log_number_of_backup_files}}\nlog4j.logger.org.apache.hadoop.yarn.server.resourcemanager.RMAppManager$ApplicationSummary=${yarn.server.resourcemanager.appsummary.logger}\nlog4j.additivity.org.apache.hadoop.yarn.server.resourcemanager.RMAppManager$ApplicationSummary=false\n\n# Appender for viewing information for errors and warnings\nyarn.ewma.cleanupInterval=300\nyarn.ewma.messageAgeLimitSeconds=86400\nyarn.ewma.maxUniqueMessages=250\nlog4j.appender.EWMA=org.apache.hadoop.yarn.util.Log4jWarningErrorMetricsAppender\nlog4j.appender.EWMA.cleanupInterval=${yarn.ewma.cleanupInterval}\nlog4j.appender.EWMA.messageAgeLimitSeconds=${yarn.ewma.messageAgeLimitSeconds}\nlog4j.appender.EWMA.maxUniqueMessages=${yarn.ewma.maxUniqueMessages}\n\n# Audit logging for ResourceManager\nrm.audit.logger=${hadoop.root.logger}\nlog4j.logger.org.apache.hadoop.yarn.server.resourcemanager.RMAuditLogger=${rm.audit.logger}\nlog4j.additivity.org.apache.hadoop.yarn.server.resourcemanager.RMAuditLogger=false\nlog4j.appender.RMAUDIT=org.apache.log4j.RollingFileAppender\nlog4j.appender.RMAUDIT.MaxBackupIndex={{yarn_rm_summary_log_number_of_backup_files}}\nlog4j.appender.RMAUDIT.File=${yarn.log.dir}/rm-audit.log\nlog4j.appender.RMAUDIT.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RMAUDIT.layout.ConversionPattern=%%d{ISO8601} %%p %%c{2}: %%m%%n\n\n# Audit logging for NodeManager\nnm.audit.logger=${hadoop.root.logger}\nlog4j.logger.org.apache.hadoop.yarn.server.nodemanager.NMAuditLogger=${nm.audit.logger}\nlog4j.additivity.org.apache.hadoop.yarn.server.nodemanager.NMAuditLogger=false\nlog4j.appender.NMAUDIT=org.apache.log4j.RollingFileAppender\nlog4j.appender.NMAUDIT.MaxBackupIndex={{yarn_rm_summary_log_number_of_backup_files}}\nlog4j.appender.NMAUDIT.File=${yarn.log.dir}/nm-audit.log\nlog4j.appender.NMAUDIT.layout=org.apache.log4j.PatternLayout\nlog4j.appender.NMAUDIT.layout.ConversionPattern=%%d{ISO8601} %%p %%c{2}: %%m%%n"
{% endraw %}            
              }
           }
        },
        {
            "capacity-scheduler" : {
                "properties" : {
                    "yarn.scheduler.capacity.maximum-am-resource-percent" : "0.5",
                    "yarn.scheduler.capacity.maximum-applications" : "10000",
                    "yarn.scheduler.capacity.node-locality-delay" : "40",
                    "yarn.scheduler.capacity.queue-mappings-override.enable" : "false",
                    "yarn.scheduler.capacity.resource-calculator" : "org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator",
                    "yarn.scheduler.capacity.root.accessible-node-labels" : "*",
                    "yarn.scheduler.capacity.root.acl_administer_queue" : "pnda",
                    "yarn.scheduler.capacity.root.acl_submit_applications" : " ",
                    "yarn.scheduler.capacity.root.applications.acl_administer_queue" : " ",
                    "yarn.scheduler.capacity.root.applications.acl_submit_applications" : " ",
                    "yarn.scheduler.capacity.root.applications.capacity" : "1",
                    "yarn.scheduler.capacity.root.applications.dev.acl_administer_queue" : " dev,prod",
                    "yarn.scheduler.capacity.root.applications.dev.acl_submit_applications" : " dev,prod",
                    "yarn.scheduler.capacity.root.applications.dev.capacity" : "1",
                    "yarn.scheduler.capacity.root.applications.dev.maximum-applications" : "100000000",
                    "yarn.scheduler.capacity.root.applications.dev.maximum-capacity" : "100",
                    "yarn.scheduler.capacity.root.applications.dev.minimum-user-limit-percent" : "100",
                    "yarn.scheduler.capacity.root.applications.dev.ordering-policy" : "fair",
                    "yarn.scheduler.capacity.root.applications.dev.ordering-policy.fair.enable-size-based-weight" : "false",
                    "yarn.scheduler.capacity.root.applications.dev.priority" : "0",
                    "yarn.scheduler.capacity.root.applications.dev.state" : "RUNNING",
                    "yarn.scheduler.capacity.root.applications.dev.user-limit-factor" : "10000",
                    "yarn.scheduler.capacity.root.applications.maximum-capacity" : "100",
                    "yarn.scheduler.capacity.root.applications.minimum-user-limit-percent" : "100",
                    "yarn.scheduler.capacity.root.applications.priority" : "0",
                    "yarn.scheduler.capacity.root.applications.prod.acl_administer_queue" : " prod",
                    "yarn.scheduler.capacity.root.applications.prod.acl_submit_applications" : " prod",
                    "yarn.scheduler.capacity.root.applications.prod.capacity" : "99",
                    "yarn.scheduler.capacity.root.applications.prod.maximum-applications" : "1000000",
                    "yarn.scheduler.capacity.root.applications.prod.maximum-capacity" : "100",
                    "yarn.scheduler.capacity.root.applications.prod.minimum-user-limit-percent" : "100",
                    "yarn.scheduler.capacity.root.applications.prod.ordering-policy" : "fair",
                    "yarn.scheduler.capacity.root.applications.prod.ordering-policy.fair.enable-size-based-weight" : "false",
                    "yarn.scheduler.capacity.root.applications.prod.priority" : "0",
                    "yarn.scheduler.capacity.root.applications.prod.state" : "RUNNING",
                    "yarn.scheduler.capacity.root.applications.prod.user-limit-factor" : "100",
                    "yarn.scheduler.capacity.root.applications.queues" : "dev,prod",
                    "yarn.scheduler.capacity.root.applications.state" : "RUNNING",
                    "yarn.scheduler.capacity.root.capacity" : "100",
                    "yarn.scheduler.capacity.root.default.acl_administer_queue" : " ",
                    "yarn.scheduler.capacity.root.default.acl_submit_applications" : "pnda",
                    "yarn.scheduler.capacity.root.default.capacity" : "99",
                    "yarn.scheduler.capacity.root.default.maximum-applications" : "10000",
                    "yarn.scheduler.capacity.root.default.maximum-capacity" : "100",
                    "yarn.scheduler.capacity.root.default.ordering-policy" : "fair",
                    "yarn.scheduler.capacity.root.default.ordering-policy.fair.enable-size-based-weight" : "false",
                    "yarn.scheduler.capacity.root.default.priority" : "0",
                    "yarn.scheduler.capacity.root.default.state" : "RUNNING",
                    "yarn.scheduler.capacity.root.default.user-limit-factor" : "1",
                    "yarn.scheduler.capacity.root.priority" : "0",
                    "yarn.scheduler.capacity.root.queues" : "applications,default"
                }
            }
        },
        {
            "mapred-site" : {
                "properties" : {
                    "mapred_log_dir_prefix" : "/var/log/pnda/hadoop-mapreduce",
                    "mapreduce.reduce.java.opts" : "-Xmx819m",
                    "mapreduce.task.io.sort.mb" : "128",
                    "mapreduce.map.memory.mb" : "384",
                    "mapreduce.reduce.memory.mb" : "1024",
                    "yarn.app.mapreduce.am.command-opts" : "-Xmx410m",
                    "mapreduce.map.java.opts" : "-Xmx410m",
                    "yarn.app.mapreduce.am.resource.mb" : "512"
                }
            }
        },
        {
            "zookeeper-env" : {
                "properties" : {
                    "zk_log_dir" : "/var/log/pnda/zookeeper"
                }
            }
        },
        {
            "zookeeper-log4j" : {
                "properties_attributes" : { },
                "properties" : {
                    "zookeeper_log_max_backup_size" : "100",
                    "zookeeper_log_number_of_backup_files" : "2",
{% raw %}
                    "content" : "\n#\n#\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#   http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing,\n# software distributed under the License is distributed on an\n# \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY\n# KIND, either express or implied.  See the License for the\n# specific language governing permissions and limitations\n# under the License.\n#\n#\n#\n\n#\n# ZooKeeper Logging Configuration\n#\n\n# DEFAULT: console appender only\nlog4j.rootLogger=INFO, CONSOLE, ROLLINGFILE\n\n# Example with rolling log file\n#log4j.rootLogger=DEBUG, CONSOLE, ROLLINGFILE\n\n# Example with rolling log file and tracing\n#log4j.rootLogger=TRACE, CONSOLE, ROLLINGFILE, TRACEFILE\n\n#\n# Log INFO level and above messages to the console\n#\nlog4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender\nlog4j.appender.CONSOLE.Threshold=INFO\nlog4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout\nlog4j.appender.CONSOLE.layout.ConversionPattern=%%d{ISO8601} - %%-5p [%%t:%%C{1}\n%%L] - %%m%%n\n\n#\n# Add ROLLINGFILE to rootLogger to get log file output\n#    Log DEBUG level and above messages to a log file\nlog4j.appender.ROLLINGFILE=org.apache.log4j.RollingFileAppender\nlog4j.appender.ROLLINGFILE.Threshold=DEBUG\nlog4j.appender.ROLLINGFILE.File={{zk_log_dir}}/zookeeper.log\n\n# Max log file size of 10MB\nlog4j.appender.ROLLINGFILE.MaxFileSize={{zookeeper_log_max_backup_size}}MB\n# uncomment the next line to limit number of backup files\nlog4j.appender.ROLLINGFILE.MaxBackupIndex={{zookeeper_log_number_of_backup_files}}\n\nlog4j.appender.ROLLINGFILE.layout=org.apache.log4j.PatternLayout\nlog4j.appender.ROLLINGFILE.layout.ConversionPattern=%%d{ISO8601} - %%-5p [%%t:%%C{1}\n%%L] - %%m%%n\n\n\n#\n# Add TRACEFILE to rootLogger to get log file output\n#    Log DEBUG level and above messages to a log file\nlog4j.appender.TRACEFILE=org.apache.log4j.FileAppender\nlog4j.appender.TRACEFILE.Threshold=TRACE\nlog4j.appender.TRACEFILE.File=zookeeper_trace.log\n\nlog4j.appender.TRACEFILE.layout=org.apache.log4j.PatternLayout\n### Notice we are including log4j's NDC here (%%x)\nlog4j.appender.TRACEFILE.layout.ConversionPattern=%%d{ISO8601} - %%-5p [%%t:%%C{1}\n%%L][%%x] - %%m%%n"
{% endraw %}
                }
            }
        }, 
        {
            "zoo.cfg" : {
                "properties" : {
                    "dataDir" : "/mnt/hadoop/zookeeper"
                }
            }
        },
        {
            "oozie-env" : {
                    "properties" : {
                    "oozie_log_dir" : "/var/log/pnda/oozie",
                    "oozie_data_dir" : "/mnt/hadoop/oozie",
                    "oozie_user" : "oozie",
                    "oozie_admin_users" : "{oozie_user}, oozie-admin",
                    "oozie_database" : "Existing MySQL / MariaDB Database"
                }
            }
        },
        {
            "oozie-site" : {
                "properties" : {
                    "oozie.service.JPAService.jdbc.password" : "oozie",
                    "oozie.service.JPAService.jdbc.username" : "oozie",
                    "oozie.service.JPAService.jdbc.url" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-1%(domain_name)s/oozie",
                    "oozie.service.JPAService.jdbc.driver" : "com.mysql.jdbc.Driver",
                    "oozie.authentication.type" : "simple",
                    "oozie.db.schema.name" : "oozie"
                }
            }
        },
        {
            "oozie-log4j" : {
                "properties_attributes" : { },
                "properties" : {
                    "oozie_log_maxhistory" : "360",
{% raw %}
                     "content" : "\n#\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#    http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License. See accompanying LICENSE file.\n#\n\n# If the Java System property 'oozie.log.dir' is not defined at Oozie start up time\n# XLogService sets its value to '${oozie.home}/logs'\n\n# The appender that Oozie uses must be named 'oozie' (i.e. log4j.appender.oozie)\n\n# Using the RollingFileAppender with the OozieRollingPolicy will roll the log file every hour and retain up to MaxHistory number of\n# log files. If FileNamePattern ends with \".gz\" it will create gzip files.\nlog4j.appender.oozie=org.apache.log4j.rolling.RollingFileAppender\nlog4j.appender.oozie.RollingPolicy=org.apache.oozie.util.OozieRollingPolicy\nlog4j.appender.oozie.File=${oozie.log.dir}/oozie.log\nlog4j.appender.oozie.Append=true\nlog4j.appender.oozie.layout=org.apache.log4j.PatternLayout\nlog4j.appender.oozie.layout.ConversionPattern=%%d{ISO8601} %%5p %%c{1}:%%L - SERVER[${oozie.instance.id}] %%m%%n\n# The FileNamePattern must end with \"-%%d{yyyy-MM-dd-HH}.gz\" or \"-%%d{yyyy-MM-dd-HH}\" and also start with the\n# value of log4j.appender.oozie.File\nlog4j.appender.oozie.RollingPolicy.FileNamePattern=${log4j.appender.oozie.File}-%%d{yyyy-MM-dd-HH}.gz\n# The MaxHistory controls how many log files will be retained (720 hours / 24 hours per day = 30 days); -1 to disable\nlog4j.appender.oozie.RollingPolicy.MaxHistory={{oozie_log_maxhistory}}\n\n\n\nlog4j.appender.oozieError=org.apache.log4j.rolling.RollingFileAppender\nlog4j.appender.oozieError.RollingPolicy=org.apache.oozie.util.OozieRollingPolicy\nlog4j.appender.oozieError.File=${oozie.log.dir}/oozie-error.log\nlog4j.appender.oozieError.Append=true\nlog4j.appender.oozieError.layout=org.apache.log4j.PatternLayout\nlog4j.appender.oozieError.layout.ConversionPattern=%%d{ISO8601} %%5p %%c{1}:%%L - SERVER[${oozie.instance.id}] %%m%%n\n# The FileNamePattern must end with \"-%%d{yyyy-MM-dd-HH}.gz\" or \"-%%d{yyyy-MM-dd-HH}\" and also start with the\n# value of log4j.appender.oozieError.File\nlog4j.appender.oozieError.RollingPolicy.FileNamePattern=${log4j.appender.oozieError.File}-%%d{yyyy-MM-dd-HH}.gz\n# The MaxHistory controls how many log files will be retained (720 hours / 24 hours per day = 30 days); -1 to disable\nlog4j.appender.oozieError.RollingPolicy.MaxHistory={{oozie_log_maxhistory}}\nlog4j.appender.oozieError.filter.1 = org.apache.log4j.varia.LevelMatchFilter\nlog4j.appender.oozieError.filter.1.levelToMatch = WARN\nlog4j.appender.oozieError.filter.2 = org.apache.log4j.varia.LevelMatchFilter\nlog4j.appender.oozieError.filter.2.levelToMatch = ERROR\nlog4j.appender.oozieError.filter.3 = org.apache.log4j.varia.LevelMatchFilter\nlog4j.appender.oozieError.filter.3.levelToMatch = FATAL\nlog4j.appender.oozieError.filter.4 = org.apache.log4j.varia.DenyAllFilter\n\n\n\n# Uncomment the below two lines to use the DailyRollingFileAppender instead\n# The DatePattern must end with either \"dd\" or \"HH\"\n#log4j.appender.oozie=org.apache.log4j.DailyRollingFileAppender\n#log4j.appender.oozie.DatePattern='.'yyyy-MM-dd-HH\n\nlog4j.appender.oozieops=org.apache.log4j.rolling.RollingFileAppender\nlog4j.appender.oozieops.RollingPolicy=org.apache.oozie.util.OozieRollingPolicy\nlog4j.appender.oozieops.File=${oozie.log.dir}/oozie-ops.log\nlog4j.appender.oozieops.Append=true\nlog4j.appender.oozieops.RollingPolicy.FileNamePattern=${log4j.appender.oozieops.File}-%%d{yyyy-MM-dd-HH}.gz\nlog4j.appender.oozieops.RollingPolicy.MaxHistory={{oozie_log_maxhistory}}\nlog4j.appender.oozieops.layout=org.apache.log4j.PatternLayout\nlog4j.appender.oozieops.layout.ConversionPattern=%%d{ISO8601} %%5p %%c{1}:%%L - %%m%%n\n\nlog4j.appender.oozieinstrumentation=org.apache.log4j.rolling.RollingFileAppender\nlog4j.appender.oozieinstrumentation.RollingPolicy=org.apache.oozie.util.OozieRollingPolicy\nlog4j.appender.oozieinstrumentation.File=${oozie.log.dir}/oozie-instrumentation.log\nlog4j.appender.oozieinstrumentation.RollingPolicy.FileNamePattern=${log4j.appender.oozieinstrumentation.File}-%%d{yyyy-MM-dd-HH}.gz\nlog4j.appender.oozieinstrumentation.RollingPolicy.MaxHistory={{oozie_log_maxhistory}}\nlog4j.appender.oozieinstrumentation.Append=true\nlog4j.appender.oozieinstrumentation.layout=org.apache.log4j.PatternLayout\nlog4j.appender.oozieinstrumentation.layout.ConversionPattern=%%d{ISO8601} %%5p %%c{1}:%%L - %%m%%n\n\nlog4j.appender.oozieaudit=org.apache.log4j.rolling.RollingFileAppender\nlog4j.appender.oozieaudit.RollingPolicy=org.apache.oozie.util.OozieRollingPolicy\nlog4j.appender.oozieaudit.File=${oozie.log.dir}/oozie-audit.log\nlog4j.appender.oozieaudit.RollingPolicy.FileNamePattern=${log4j.appender.oozieaudit.File}-%%d{yyyy-MM-dd-HH}.gz\nlog4j.appender.oozieaudit.RollingPolicy.MaxHistory={{oozie_log_maxhistory}}\nlog4j.appender.oozieaudit.Append=true\nlog4j.appender.oozieaudit.layout=org.apache.log4j.PatternLayout\nlog4j.appender.oozieaudit.layout.ConversionPattern=%%d{ISO8601} %%5p %%c{1}:%%L - %%m%%n\n\nlog4j.appender.openjpa=org.apache.log4j.rolling.RollingFileAppender\nlog4j.appender.openjpa.RollingPolicy=org.apache.oozie.util.OozieRollingPolicy\nlog4j.appender.openjpa.File=${oozie.log.dir}/oozie-jpa.log\nlog4j.appender.openjpa.RollingPolicy.FileNamePattern=${log4j.appender.openjpa.File}-%%d{yyyy-MM-dd-HH}.gz\nlog4j.appender.openjpa.RollingPolicy.MaxHistory={{oozie_log_maxhistory}}\nlog4j.appender.openjpa.Append=true\nlog4j.appender.openjpa.layout=org.apache.log4j.PatternLayout\nlog4j.appender.openjpa.layout.ConversionPattern=%%d{ISO8601} %%5p %%c{1}:%%L - %%m%%n\n\nlog4j.logger.openjpa=INFO, openjpa\nlog4j.logger.oozieops=INFO, oozieops\nlog4j.logger.oozieinstrumentation=ALL, oozieinstrumentation\nlog4j.logger.oozieaudit=ALL, oozieaudit\nlog4j.logger.org.apache.oozie=INFO, oozie, oozieError\nlog4j.logger.org.apache.hadoop=WARN, oozie\nlog4j.logger.org.mortbay=WARN, oozie\nlog4j.logger.org.hsqldb=WARN, oozie"
{% endraw %}
                }
            }
        },
        {
            "hive-env" : {
                "properties" : {
                    "hive_ambari_database" : "MySQL",
                    "hive_ambari_host" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hive_database" : "MySQL Database",
                    "hive_database_name" : "hive",
                    "hive_database_type" : "mysql",
                    "hive_existing_mssql_server_2_host" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hive_existing_mssql_server_host" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hive_existing_mysql_host" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hive_hostname" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hive_user" : "hive",
                    "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                    "javax.jdo.option.ConnectionPassword" : "hive",
                    "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-1%(domain_name)s/hive",
                    "javax.jdo.option.ConnectionUserName" : "hive",
                    "hive_log_dir" : "/var/log/pnda/hive",
                    "hive.heapsize" : "512",
                    "hcat_log_dir" : "/var/log/pnda/webhcat",
                    "hive.metastore.heapsize" : "1024"
                }
            }
        },
        {
            "hive-site" : {
                "properties" : {
                    "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                    "javax.jdo.option.ConnectionPassword" : "hive",
                    "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-1%(domain_name)s/hive?createDatabaseIfNotExist=true",
                    "javax.jdo.option.ConnectionUserName" : "hive",
                    "hive.server2.transport.mode": "http"
                }
            }
        },
        {
            "hive-log4j" : {
                "properties_attributes" : { },
                "properties" : {
                    "hive_log_maxbackupindex" : "2",
                    "hive_log_maxfilesize" : "100",
{% raw %}
                    "content" : "\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\n# Define some default values that can be overridden by system properties\nhive.log.threshold=ALL\nhive.root.logger={{hive_log_level}},DRFA\nhive.log.dir=${java.io.tmpdir}/${user.name}\nhive.log.file=hive.log\n\n# Define the root logger to the system property \"hadoop.root.logger\".\nlog4j.rootLogger=${hive.root.logger}, EventCounter\n\n# Logging Threshold\nlog4j.threshold=${hive.log.threshold}\n\n#\n# Daily Rolling File Appender\n#\n# Use the PidDailyerRollingFileAppend class instead if you want to use separate log files\n# for different CLI session.\n#\n# log4j.appender.DRFA=org.apache.hadoop.hive.ql.log.PidDailyRollingFileAppender\n\nlog4j.appender.DRFA=org.apache.log4j.DailyRollingFileAppender\n\nlog4j.appender.DRFA.File=${hive.log.dir}/${hive.log.file}\n\n# Rollver at midnight\nlog4j.appender.DRFA.DatePattern=.yyyy-MM-dd\n\n# 30-day backup\nlog4j.appender.DRFA.MaxBackupIndex={{hive_log_maxbackupindex}}\nlog4j.appender.DRFA.MaxFileSize={{hive_log_maxfilesize}}MB\nlog4j.appender.DRFA.layout=org.apache.log4j.PatternLayout\n\n\n# Pattern format: Date LogLevel LoggerName LogMessage\n#log4j.appender.DRFA.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\n# Debugging Pattern format\nlog4j.appender.DRFA.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t]: %%c{2} (%%F:%%M(%%L)) - %%m%%n\n\n\n#\n# console\n# Add \"console\" to rootlogger above if you want to use this\n#\n\nlog4j.appender.console=org.apache.log4j.ConsoleAppender\nlog4j.appender.console.target=System.err\nlog4j.appender.console.layout=org.apache.log4j.PatternLayout\nlog4j.appender.console.layout.ConversionPattern=%%d{yy/MM/dd HH:mm:ss} [%%t]: %%p %%c{2}: %%m%%n\nlog4j.appender.console.encoding=UTF-8\n\n#custom logging levels\n#log4j.logger.xxx=DEBUG\n\n#\n# Event Counter Appender\n# Sends counts of logging messages at different severity levels to Hadoop Metrics.\n#\nlog4j.appender.EventCounter=org.apache.hadoop.hive.shims.HiveEventCounter\n\n\nlog4j.category.DataNucleus=ERROR,DRFA\nlog4j.category.Datastore=ERROR,DRFA\nlog4j.category.Datastore.Schema=ERROR,DRFA\nlog4j.category.JPOX.Datastore=ERROR,DRFA\nlog4j.category.JPOX.Plugin=ERROR,DRFA\nlog4j.category.JPOX.MetaData=ERROR,DRFA\nlog4j.category.JPOX.Query=ERROR,DRFA\nlog4j.category.JPOX.General=ERROR,DRFA\nlog4j.category.JPOX.Enhancer=ERROR,DRFA\n\n\n# Silence useless ZK logs\nlog4j.logger.org.apache.zookeeper.server.NIOServerCnxn=WARN,DRFA\nlog4j.logger.org.apache.zookeeper.ClientCnxnSocketNIO=WARN,DRFA"
{% endraw %}
                }
            }
        },
        {
            "hbase-site" : {
                "properties" : {
                    "zookeeper.session.timeout" : "300000",
                    "hbase.tmp.dir" : "/mnt/hadoop/hbase/tmp"
                }
            }
        },
        {
            "hbase-env" : {
                "properties" : {
                    "hbase_master_heapsize" : "384m",
                    "hbase_log_dir" : "/var/log/pnda/hbase",
                    "hbase_regionserver_heapsize" : "768m"
                }
            }
        },
        {
            "hbase-log4j" : {
               "properties_attributes" : { },
               "properties" : {
                   "hbase_security_log_maxfilesize" : "100",
                   "hbase_security_log_maxbackupindex" : "2",
                   "hbase_log_maxfilesize" : "100",
                   "hbase_log_maxbackupindex" : "2", 
{% raw %}
                   "content" : "\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\n\n# Define some default values that can be overridden by system properties\nhbase.root.logger=INFO,console\nhbase.security.logger=INFO,console\nhbase.log.dir=.\nhbase.log.file=hbase.log\n\n# Define the root logger to the system property \"hbase.root.logger\".\nlog4j.rootLogger=${hbase.root.logger}\n\n# Logging Threshold\nlog4j.threshold=ALL\n\n#\n# Daily Rolling File Appender\n#\nlog4j.appender.DRFA=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.DRFA.File=${hbase.log.dir}/${hbase.log.file}\n\n# Rollver at midnight\nlog4j.appender.DRFA.DatePattern=.yyyy-MM-dd\n\n# 30-day backup\nlog4j.appender.DRFA.MaxBackupIndex={{hbase_log_maxbackupindex}}\nlog4j.appender.DRFA.layout=org.apache.log4j.PatternLayout\n\n# Pattern format: Date LogLevel LoggerName LogMessage\nlog4j.appender.DRFA.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t] %%c{2}: %%m%%n\n\n# Rolling File Appender properties\nhbase.log.maxfilesize={{hbase_log_maxfilesize}}MB\nhbase.log.maxbackupindex={{hbase_log_maxbackupindex}}\n\n# Rolling File Appender\nlog4j.appender.RFA=org.apache.log4j.RollingFileAppender\nlog4j.appender.RFA.File=${hbase.log.dir}/${hbase.log.file}\n\nlog4j.appender.RFA.MaxFileSize=${hbase.log.maxfilesize}\nlog4j.appender.RFA.MaxBackupIndex=${hbase.log.maxbackupindex}\n\nlog4j.appender.RFA.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RFA.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t] %%c{2}: %%m%%n\n\n#\n# Security audit appender\n#\nhbase.security.log.file=SecurityAuth.audit\nhbase.security.log.maxfilesize={{hbase_security_log_maxfilesize}}MB\nhbase.security.log.maxbackupindex={{hbase_security_log_maxbackupindex}}\nlog4j.appender.RFAS=org.apache.log4j.RollingFileAppender\nlog4j.appender.RFAS.File=${hbase.log.dir}/${hbase.security.log.file}\nlog4j.appender.RFAS.MaxFileSize=${hbase.security.log.maxfilesize}\nlog4j.appender.RFAS.MaxBackupIndex=${hbase.security.log.maxbackupindex}\nlog4j.appender.RFAS.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RFAS.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\nlog4j.category.SecurityLogger=${hbase.security.logger}\nlog4j.additivity.SecurityLogger=false\n#log4j.logger.SecurityLogger.org.apache.hadoop.hbase.security.access.AccessController=TRACE\n\n#\n# Null Appender\n#\nlog4j.appender.NullAppender=org.apache.log4j.varia.NullAppender\n\n#\n# console\n# Add \"console\" to rootlogger above if you want to use this\n#\nlog4j.appender.console=org.apache.log4j.ConsoleAppender\nlog4j.appender.console.target=System.err\nlog4j.appender.console.layout=org.apache.log4j.PatternLayout\nlog4j.appender.console.layout.ConversionPattern=%%d{ISO8601} %%-5p [%%t] %%c{2}: %%m%%n\n\n# Custom Logging levels\n\nlog4j.logger.org.apache.zookeeper=INFO\n#log4j.logger.org.apache.hadoop.fs.FSNamesystem=DEBUG\nlog4j.logger.org.apache.hadoop.hbase=INFO\n# Make these two classes INFO-level. Make them DEBUG to see more zk debug.\nlog4j.logger.org.apache.hadoop.hbase.zookeeper.ZKUtil=INFO\nlog4j.logger.org.apache.hadoop.hbase.zookeeper.ZooKeeperWatcher=INFO\n#log4j.logger.org.apache.hadoop.dfs=DEBUG\n# Set this class to log INFO only otherwise its OTT\n# Enable this to get detailed connection error/retry logging.\n# log4j.logger.org.apache.hadoop.hbase.client.HConnectionManager$HConnectionImplementation=TRACE\n\n\n# Uncomment this line to enable tracing on _every_ RPC call (this can be a lot of output)\n#log4j.logger.org.apache.hadoop.ipc.HBaseServer.trace=DEBUG\n\n# Uncomment the below if you want to remove logging of client region caching'\n# and scan of .META. messages\n# log4j.logger.org.apache.hadoop.hbase.client.HConnectionManager$HConnectionImplementation=INFO\n# log4j.logger.org.apache.hadoop.hbase.client.MetaScanner=INFO"
{% endraw %}        
               }
            }
        },
        {
            "hadoop-env" : {
                "properties" : {
                    "dtnode_heapsize" : "1024m",
                    "hadoop_heapsize" : "1024",
                    "namenode_heapsize": "1024m",
                    "namenode_opt_maxnewsize": "361m",
                    "namenode_opt_newsize": "361m",
                    "hdfs_log_dir_prefix" : "/var/log/pnda/hadoop"
                }
            }
        },
        {
            "hdfs-site" : {
                "properties" : {
                    "dfs.replication" : "3",
                    "dfs.replication.max" : "50",
                    "dfs.datanode.data.dir" : "{{ data_volumes }}",
                    "dfs.namenode.checkpoint.dir" : "/mnt/hadoop/hdfs/snn",
                    "dfs.namenode.name.dir" : "/mnt/hadoop/hdfs/nn"
                }
            }
        },
        {
            "hdfs-log4j" : {
                "properties_attributes" : { },
                "properties" : {
                    "hadoop_security_log_max_backup_size" : "100",
                    "hadoop_security_log_number_of_backup_files" : "2",
                    "hadoop_log_max_backup_size" : "100",
                    "hadoop_log_number_of_backup_files" : "2",
{% raw %}
                    "content" : "\n#\n# Licensed to the Apache Software Foundation (ASF) under one\n# or more contributor license agreements.  See the NOTICE file\n# distributed with this work for additional information\n# regarding copyright ownership.  The ASF licenses this file\n# to you under the Apache License, Version 2.0 (the\n# \"License\"); you may not use this file except in compliance\n# with the License.  You may obtain a copy of the License at\n#\n#  http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing,\n# software distributed under the License is distributed on an\n# \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY\n# KIND, either express or implied.  See the License for the\n# specific language governing permissions and limitations\n# under the License.\n#\n\n\n# Define some default values that can be overridden by system properties\n# To change daemon root logger use hadoop_root_logger in hadoop-env\nhadoop.root.logger=INFO,console\nhadoop.log.dir=.\nhadoop.log.file=hadoop.log\n\n\n# Define the root logger to the system property \"hadoop.root.logger\".\nlog4j.rootLogger=${hadoop.root.logger}, EventCounter\n\n# Logging Threshold\nlog4j.threshhold=ALL\n\n#\n# Daily Rolling File Appender\n#\n\nlog4j.appender.DRFA=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.DRFA.File=${hadoop.log.dir}/${hadoop.log.file}\n\n# Rollver at midnight\nlog4j.appender.DRFA.DatePattern=.yyyy-MM-dd\n\n# 30-day backup\nlog4j.appender.DRFA.MaxBackupIndex={{hadoop_log_number_of_backup_files}}\nlog4j.appender.DRFA.layout=org.apache.log4j.PatternLayout\n\n# Pattern format: Date LogLevel LoggerName LogMessage\nlog4j.appender.DRFA.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\n# Debugging Pattern format\n#log4j.appender.DRFA.layout.ConversionPattern=%%d{ISO8601} %%-5p %%c{2} (%%F:%%M(%%L)) - %%m%%n\n\n\n#\n# console\n# Add \"console\" to rootlogger above if you want to use this\n#\n\nlog4j.appender.console=org.apache.log4j.ConsoleAppender\nlog4j.appender.console.target=System.err\nlog4j.appender.console.layout=org.apache.log4j.PatternLayout\nlog4j.appender.console.layout.ConversionPattern=%%d{yy/MM/dd HH:mm:ss} %%p %%c{2}: %%m%%n\n\n#\n# TaskLog Appender\n#\n\n#Default values\nhadoop.tasklog.taskid=null\nhadoop.tasklog.iscleanup=false\nhadoop.tasklog.noKeepSplits=4\nhadoop.tasklog.totalLogFileSize=100\nhadoop.tasklog.purgeLogSplits=true\nhadoop.tasklog.logsRetainHours=12\n\nlog4j.appender.TLA=org.apache.hadoop.mapred.TaskLogAppender\nlog4j.appender.TLA.taskId=${hadoop.tasklog.taskid}\nlog4j.appender.TLA.isCleanup=${hadoop.tasklog.iscleanup}\nlog4j.appender.TLA.totalLogFileSize=${hadoop.tasklog.totalLogFileSize}\n\nlog4j.appender.TLA.layout=org.apache.log4j.PatternLayout\nlog4j.appender.TLA.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\n\n#\n#Security audit appender\n#\nhadoop.security.logger=INFO,console\nhadoop.security.log.maxfilesize={{hadoop_security_log_max_backup_size}}MB\nhadoop.security.log.maxbackupindex={{hadoop_security_log_number_of_backup_files}}\nlog4j.category.SecurityLogger=${hadoop.security.logger}\nhadoop.security.log.file=SecurityAuth.audit\nlog4j.additivity.SecurityLogger=false\nlog4j.appender.DRFAS=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.DRFAS.File=${hadoop.log.dir}/${hadoop.security.log.file}\nlog4j.appender.DRFAS.layout=org.apache.log4j.PatternLayout\nlog4j.appender.DRFAS.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\nlog4j.appender.DRFAS.DatePattern=.yyyy-MM-dd\nlog4j.appender.DRFAS.MaxBackupIndex={{hadoop_security_log_number_of_backup_files}}\n\nlog4j.appender.RFAS=org.apache.log4j.RollingFileAppender\nlog4j.appender.RFAS.File=${hadoop.log.dir}/${hadoop.security.log.file}\nlog4j.appender.RFAS.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RFAS.layout.ConversionPattern=%%d{ISO8601} %%p %%c: %%m%%n\nlog4j.appender.RFAS.MaxFileSize=${hadoop.security.log.maxfilesize}\nlog4j.appender.RFAS.MaxBackupIndex=${hadoop.security.log.maxbackupindex}\n\n#\n# hdfs audit logging\n#\nhdfs.audit.logger=INFO,console\nlog4j.logger.org.apache.hadoop.hdfs.server.namenode.FSNamesystem.audit=${hdfs.audit.logger}\nlog4j.additivity.org.apache.hadoop.hdfs.server.namenode.FSNamesystem.audit=false\nlog4j.appender.DRFAAUDIT=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.DRFAAUDIT.File=${hadoop.log.dir}/hdfs-audit.log\nlog4j.appender.DRFAAUDIT.layout=org.apache.log4j.PatternLayout\nlog4j.appender.DRFAAUDIT.layout.ConversionPattern=%%d{ISO8601} %%p %%c{2}: %%m%%n\nlog4j.appender.DRFAAUDIT.DatePattern=.yyyy-MM-dd\nlog4j.appender.DRFAAUDIT.MaxBackupIndex={{hadoop_log_number_of_backup_files}}\n\n#\n# NameNode metrics logging.\n# The default is to retain two namenode-metrics.log files up to 64MB each.\n#\nnamenode.metrics.logger=INFO,NullAppender\nlog4j.logger.NameNodeMetricsLog=${namenode.metrics.logger}\nlog4j.additivity.NameNodeMetricsLog=false\nlog4j.appender.NNMETRICSRFA=org.apache.log4j.RollingFileAppender\nlog4j.appender.NNMETRICSRFA.File=${hadoop.log.dir}/namenode-metrics.log\nlog4j.appender.NNMETRICSRFA.layout=org.apache.log4j.PatternLayout\nlog4j.appender.NNMETRICSRFA.layout.ConversionPattern=%%d{ISO8601} %%m%%n\nlog4j.appender.NNMETRICSRFA.MaxBackupIndex=1\nlog4j.appender.NNMETRICSRFA.MaxFileSize=64MB\n\n#\n# mapred audit logging\n#\nmapred.audit.logger=INFO,console\nlog4j.logger.org.apache.hadoop.mapred.AuditLogger=${mapred.audit.logger}\nlog4j.additivity.org.apache.hadoop.mapred.AuditLogger=false\nlog4j.appender.MRAUDIT=org.apache.log4j.DailyRollingFileAppender\nlog4j.appender.MRAUDIT.File=${hadoop.log.dir}/mapred-audit.log\nlog4j.appender.MRAUDIT.layout=org.apache.log4j.PatternLayout\nlog4j.appender.MRAUDIT.layout.ConversionPattern=%%d{ISO8601} %%p %%c{2}: %%m%%n\nlog4j.appender.MRAUDIT.DatePattern=.yyyy-MM-dd\nlog4j.appender.MRAUDIT.MaxBackupIndex={{hadoop_log_number_of_backup_files}}\n\n#\n# Rolling File Appender\n#\n\nlog4j.appender.RFA=org.apache.log4j.RollingFileAppender\nlog4j.appender.RFA.File=${hadoop.log.dir}/${hadoop.log.file}\n\n# Logfile size and and 30-day backups\nlog4j.appender.RFA.MaxFileSize={{hadoop_log_max_backup_size}}MB\nlog4j.appender.RFA.MaxBackupIndex={{hadoop_log_number_of_backup_files}}\n\nlog4j.appender.RFA.layout=org.apache.log4j.PatternLayout\nlog4j.appender.RFA.layout.ConversionPattern=%%d{ISO8601} %%-5p %%c{2} - %%m%%n\nlog4j.appender.RFA.layout.ConversionPattern=%%d{ISO8601} %%-5p %%c{2} (%%F:%%M(%%L)) - %%m%%n\n\n\n# Custom Logging levels\n\nhadoop.metrics.log.level=INFO\n#log4j.logger.org.apache.hadoop.mapred.JobTracker=DEBUG\n#log4j.logger.org.apache.hadoop.mapred.TaskTracker=DEBUG\n#log4j.logger.org.apache.hadoop.fs.FSNamesystem=DEBUG\nlog4j.logger.org.apache.hadoop.metrics2=${hadoop.metrics.log.level}\n\n# Jets3t library\nlog4j.logger.org.jets3t.service.impl.rest.httpclient.RestS3Service=ERROR\n\n#\n# Null Appender\n# Trap security logger on the hadoop client side\n#\nlog4j.appender.NullAppender=org.apache.log4j.varia.NullAppender\n\n#\n# Event Counter Appender\n# Sends counts of logging messages at different severity levels to Hadoop Metrics.\n#\nlog4j.appender.EventCounter=org.apache.hadoop.log.metrics.EventCounter\n\n# Removes \"deprecated\" messages\nlog4j.logger.org.apache.hadoop.conf.Configuration.deprecation=WARN\n\n#\n# HDFS block state change log from block manager\n#\n# Uncomment the following to suppress normal block state change\n# messages from BlockManager in NameNode.\n#log4j.logger.BlockStateChange=WARN"
{% endraw %}
                }
            }
        },
        {
            "core-site" : {
                "properties_attributes" : {
                    "final" : {
                        "fs.defaultFS" : "true"
                    }
                },
                "properties" : {
                    "fs.defaultFS" : "hdfs://%(cluster_name)s-hadoop-mgr-1%(domain_name)s:8020",
                    "fs.trash.interval" : "360",
                    "ha.failover-controller.active-standby-elector.zk.op.retries" : "120",
                    "hadoop.http.authentication.simple.anonymous.allowed" : "true",
                    "hadoop.http.staticuser.user": "{{ pnda_user }}",
                    "hadoop.proxyuser.hcat.groups" : "users",
                    "hadoop.proxyuser.hcat.hosts" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hadoop.proxyuser.hdfs.groups" : "*",
                    "hadoop.proxyuser.hdfs.hosts" : "*",
                    "hadoop.proxyuser.hive.groups" : "*",
                    "hadoop.proxyuser.hive.hosts" : "*",
                    "hadoop.proxyuser.ambari.groups" : "*",
                    "hadoop.proxyuser.ambari.hosts" : "*",
                    "hadoop.proxyuser.httpfs.groups" : "*",
                    "hadoop.proxyuser.httpfs.hosts" : "*",
                    "hadoop.proxyuser.root.groups" : "*",
                    "hadoop.proxyuser.root.hosts" : "*",
                    "hadoop.proxyuser.oozie.groups" : "*",
                    "hadoop.proxyuser.oozie.hosts" : "%(cluster_name)s-hadoop-mgr-1%(domain_name)s",
                    "hadoop.security.auth_to_local" : "DEFAULT",
                    "hadoop.security.authentication" : "simple",
                    "hadoop.security.authorization" : "false",
                    "hadoop.tmp.dir" : "/mnt/hadoop-tmp/${user.name}",
                    "io.compression.codecs" : "org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.DefaultCodec,org.apache.hadoop.io.compress.SnappyCodec",
                    "io.file.buffer.size" : "131072",
                    "io.serializations" : "org.apache.hadoop.io.serializer.WritableSerialization",
                    "ipc.client.connect.max.retries" : "50",
                    "ipc.client.connection.maxidletime" : "30000",
                    "ipc.client.idlethreshold" : "8000",
                    "ipc.server.tcpnodelay" : "true",
                    "mapreduce.jobtracker.webinterface.trusted" : "false",
                    "proxyuser_group" : "users",
                    "fs.swift.impl" : "org.apache.hadoop.fs.swift.snative.SwiftNativeFileSystem",
                    "fs.swift.service.pnda.auth.url" : "{{ keystone_auth_url }}",
                    "fs.swift.service.pnda.username" : "{{ keystone_user }}",
                    "fs.swift.service.pnda.tenant" : "{{ keystone_tenant }}",
                    "fs.swift.service.pnda.region" : "{{ region }}",
                    "fs.swift.service.pnda.public" : "true",
                    "fs.swift.service.pnda.password" : "{{ keystone_password }}",
                    "fs.s3a.access.key" : "{{ aws_key }}",
                    "fs.s3a.secret.key" : "{{ aws_secret_key }}"
                }
            }
        }
    ],
    "host_groups" : [
        {
            "name" : "MGR01",
            "components" : [
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "ZOOKEEPER_SERVER"
                },
                {
                "name" : "NAMENODE"
                },
                {
                "name" : "SECONDARY_NAMENODE"
                },
                {
                "name" : "HBASE_MASTER"
                },
                {
                "name" : "RESOURCEMANAGER"
                },
                {
                "name" : "HISTORYSERVER"
                },
                {
                "name" : "SPARK_JOBHISTORYSERVER"
                },
                {
                "name" : "SPARK2_JOBHISTORYSERVER"
                },
                {
                "name" : "APP_TIMELINE_SERVER"
                },
                {
                "name" : "HIVE_SERVER"
                },
                {
                "name" : "HIVE_METASTORE"
                },
                {
                "name" : "WEBHCAT_SERVER"
                },
                {
                "name" : "OOZIE_SERVER"
                },
                {
                "name" : "HDFS_CLIENT"
                },
                {
                "name" : "YARN_CLIENT"
                },
                {
                "name" : "MAPREDUCE2_CLIENT"
                },
                {
                "name" : "ZOOKEEPER_CLIENT"
                },
                {
                "name" : "PIG"
                },
                {
                "name" : "TEZ_CLIENT"
                },
                {
                "name" : "OOZIE_CLIENT"
                },
                {
                "name" : "SPARK_CLIENT"
                },
                {
                "name" : "SPARK2_CLIENT"
                }
            ],
            "cardinality" : "1"
        },
        {
            "name" : "DATANODE",
            "components" : [
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "DATANODE"
                },
                {
                "name" : "NODEMANAGER"
                },
                {
                "name" : "HBASE_REGIONSERVER"
                },
                {
                "name" : "HDFS_CLIENT"
                },
                {
                "name" : "YARN_CLIENT"
                },
                {
                "name" : "MAPREDUCE2_CLIENT"
                },
                {
                "name" : "ZOOKEEPER_CLIENT"
                }
            ],
            "cardinality" : "1+"
        },
        {
            "name" : "EDGE",
            "components" : [
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "METRICS_COLLECTOR"
                },
                {
                "name" : "ZOOKEEPER_CLIENT"
                },
                {
                "name" : "PIG"
                },
                {
                "name" : "OOZIE_CLIENT"
                },
                {
                "name" : "HBASE_CLIENT"
                },
                {
                "name" : "HCAT"
                },
                {
                "name" : "TEZ_CLIENT"
                },
                {
                "name" : "SPARK_CLIENT"
                },
                {
                "name" : "SLIDER"
                },
                {
                "name" : "SQOOP"
                },
                {
                "name" : "HDFS_CLIENT"
                },
                {
                "name" : "HIVE_CLIENT"
                },
                {
                "name" : "YARN_CLIENT"
                },
                {
                "name" : "MAPREDUCE2_CLIENT"
                },
                {
                "name" : "SPARK2_CLIENT"
                }
            ],
            "cardinality" : "1+"
        }
    ],
    "Blueprints" : {
        "blueprint_name" : "pnda-blueprint",
        "stack_name" : "HDP",
        "stack_version" : "2.6"
    }
}'''
