"""
Name:       cfg_production
Purpose:    Configuration for this particular flavor of PNDA

Author:     PNDA team
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
                    "metrics_collector_heapsize" : "1024",
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
                    "cluster.zookeeper.quorum" : "%(cluster_name)s-hadoop-mgr-1,%(cluster_name)s-hadoop-mgr-2,%(cluster_name)s-hadoop-mgr-4",
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
                    "hbase_log_dir" : "/var/log/pnda/ambari-metrics-collector",
                    "hbase_master_heapsize": "1024",
                    "hbase_regionserver_heapsize" : "1536"
                }
            }
        },
        {
            "spark-env" : {
                "properties" : {
                    "spark_pid_dir" : "/var/run/spark",
                    "spark_daemon_memory" : "1024",
                    "spark_log_dir" : "/var/log/pnda/spark",
{% raw %}
                    "content" : "\n#!/usr/bin/env bash\n\n# This file is sourced when running various Spark programs.\n# Copy it as spark-env.sh and edit that to configure Spark for your site.\n\n# Options read in YARN client mode\n#SPARK_EXECUTOR_INSTANCES=\"2\" #Number of workers to start (Default: 2)\nSPARK_EXECUTOR_CORES=\"1\" #Number of cores for the workers (Default: 1).\nSPARK_EXECUTOR_MEMORY=\"1G\" #Memory per Worker (e.g. 1000M, 2G) (Default: 1G)\nSPARK_DRIVER_MEMORY=\"512M\" #Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)\n#SPARK_YARN_APP_NAME=\"spark\" #The name of your application (Default: Spark)\n#SPARK_YARN_QUEUE=\"~@~Xdefault~@~Y\" #The hadoop queue to use for allocation requests (Default: @~Xdefault~@~Y)\n#SPARK_YARN_DIST_FILES=\"\" #Comma separated list of files to be distributed with the job.\n#SPARK_YARN_DIST_ARCHIVES=\"\" #Comma separated list of archives to be distributed with the job.\n\n# Generic options for the daemons used in the standalone deploy mode\n\n# Alternate conf dir. (Default: ${SPARK_HOME}/conf)\nexport SPARK_CONF_DIR=${SPARK_CONF_DIR:-{{spark_home}}/conf}\n\n# Where log files are stored.(Default:${SPARK_HOME}/logs)\n#export SPARK_LOG_DIR=${SPARK_HOME:-{{spark_home}}}/logs\nexport SPARK_LOG_DIR={{spark_log_dir}}\n\n# Where the pid file is stored. (Default: /tmp)\nexport SPARK_PID_DIR={{spark_pid_dir}}\n\n# A string representing this instance of spark.(Default: $USER)\nSPARK_IDENT_STRING=$USER\n\n# The scheduling priority for daemons. (Default: 0)\nSPARK_NICENESS=0\n\nexport HADOOP_HOME=${HADOOP_HOME:-{{hadoop_home}}}\nexport HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-{{hadoop_conf_dir}}}\n\n# The java implementation to use.\nexport JAVA_HOME={{java_home}}\n\n#Memory for Master, Worker and history server (default: 1024MB)\nexport SPARK_DAEMON_MEMORY={{spark_daemon_memory}}m\n\nif [ -d \"/etc/tez/conf/\" ]; then\n  export TEZ_CONF_DIR=/etc/tez/conf\nelse\n  export TEZ_CONF_DIR=\nfi"
{% endraw %}
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
{% raw %}
                    "content" : "\n#!/usr/bin/env bash\n\n# This file is sourced when running various Spark programs.\n# Copy it as spark-env.sh and edit that to configure Spark for your site.\n\n# Options read in YARN client mode\n#SPARK_EXECUTOR_INSTANCES=\"2\" #Number of workers to start (Default: 2)\n#SPARK_EXECUTOR_CORES=\"1\" #Number of cores for the workers (Default: 1).\n#SPARK_EXECUTOR_MEMORY=\"1G\" #Memory per Worker (e.g. 1000M, 2G) (Default: 1G)\n#SPARK_DRIVER_MEMORY=\"512M\" #Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)\n#SPARK_YARN_APP_NAME=\"spark\" #The name of your application (Default: Spark)\n#SPARK_YARN_QUEUE=\"default\" #The hadoop queue to use for allocation requests (Default: default)\n#SPARK_YARN_DIST_FILES=\"\" #Comma separated list of files to be distributed with the job.\n#SPARK_YARN_DIST_ARCHIVES=\"\" #Comma separated list of archives to be distributed with the job.\n\n# Generic options for the daemons used in the standalone deploy mode\n\n# Alternate conf dir. (Default: ${SPARK_HOME}/conf)\nexport SPARK_CONF_DIR=${SPARK_CONF_DIR:-{{spark_home}}/conf}\n\n# Where log files are stored.(Default:${SPARK_HOME}/logs)\n#export SPARK_LOG_DIR=${SPARK_HOME:-{{spark_home}}}/logs\nexport SPARK_LOG_DIR={{spark_log_dir}}\n\n# Where the pid file is stored. (Default: /tmp)\nexport SPARK_PID_DIR={{spark_pid_dir}}\n\n#Memory for Master, Worker and history server (default: 1024MB)\nexport SPARK_DAEMON_MEMORY={{spark_daemon_memory}}m\n\n# A string representing this instance of spark.(Default: $USER)\nSPARK_IDENT_STRING=$USER\n\n# The scheduling priority for daemons. (Default: 0)\nSPARK_NICENESS=0\n\nexport HADOOP_HOME=${HADOOP_HOME:-{{hadoop_home}}}\nexport HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-{{hadoop_conf_dir}}}\n\n# The java implementation to use.\nexport JAVA_HOME={{java_home}}"
{% endraw %}
                }
            }
        },
        {
            "yarn-env" : {
                "properties" : {
                    "yarn_log_dir_prefix" : "/var/log/pnda/hadoop-yarn",
                    "resourcemanager_heapsize" : "4096",
                    "nodemanager_heapsize": "4096"
                }
            }
        },
        {
            "yarn-site" : {
                "properties" : {
                    "yarn.nodemanager.log-dirs" : "/var/log/pnda/hadoop-yarn/container",
                    "yarn.nodemanager.local-dirs" : "/mnt/hadoop/yarn/nm",
                    "yarn.nodemanager.resource.cpu-vcores" : "48",
                    "yarn.nodemanager.resource.memory-mb" : "78848",
                    "yarn.nodemanager.vmem-check-enabled": "false",
                    "yarn.log-aggregation.retain-seconds" : "265000",
                    "yarn.scheduler.minimum-allocation-vcores" : "1",
                    "yarn.scheduler.maximum-allocation-vcores" : "48",
                    "yarn.scheduler.minimum-allocation-mb" : "1024",
                    "yarn.scheduler.maximum-allocation-mb": "78848",
                    "yarn.acl.enable" : "true",
                    "hadoop.registry.rm.enabled" : "false",
                    "hadoop.registry.zk.quorum" : "%(cluster_name)s-hadoop-mgr-1:2181,%(cluster_name)s-hadoop-mgr-2:2181,%(cluster_name)s-hadoop-mgr-4:2181",
                    "yarn.log.server.url" : "http://%(cluster_name)s-hadoop-mgr-4:19888/jobhistory/logs",
                    "yarn.resourcemanager.address" : "%(cluster_name)s-hadoop-mgr-1:8050",
                    "yarn.resourcemanager.admin.address" : "%(cluster_name)s-hadoop-mgr-1:8141",
                    "yarn.resourcemanager.cluster-id" : "yarn-cluster",
                    "yarn.resourcemanager.ha.automatic-failover.zk-base-path" : "/yarn-leader-election",
                    "yarn.resourcemanager.ha.enabled" : "true",
                    "yarn.resourcemanager.ha.rm-ids" : "rm1,rm2",
                    "yarn.resourcemanager.hostname" : "%(cluster_name)s-hadoop-mgr-1",
                    "yarn.resourcemanager.hostname.rm1" : "%(cluster_name)s-hadoop-mgr-1",
                    "yarn.resourcemanager.hostname.rm2" : "%(cluster_name)s-hadoop-mgr-2",
                    "yarn.resourcemanager.recovery.enabled" : "true",
                    "yarn.resourcemanager.resource-tracker.address" : "%(cluster_name)s-hadoop-mgr-1:8025",
                    "yarn.resourcemanager.scheduler.address" : "%(cluster_name)s-hadoop-mgr-1:8030",
                    "yarn.resourcemanager.store.class" : "org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore",
                    "yarn.resourcemanager.webapp.address" : "%(cluster_name)s-hadoop-mgr-1:8088",
                    "yarn.resourcemanager.webapp.address.rm1" : "%(cluster_name)s-hadoop-mgr-1:8088",
                    "yarn.resourcemanager.webapp.address.rm2" : "%(cluster_name)s-hadoop-mgr-2:8088",
                    "yarn.resourcemanager.webapp.https.address" : "%(cluster_name)s-hadoop-mgr-1:8090",
                    "yarn.resourcemanager.webapp.https.address.rm1" : "%(cluster_name)s-hadoop-mgr-1:8090",
                    "yarn.resourcemanager.webapp.https.address.rm2" : "%(cluster_name)s-hadoop-mgr-2:8090",
                    "yarn.timeline-service.address" : "%(cluster_name)s-hadoop-mgr-3:10200",
                    "yarn.timeline-service.webapp.address" : "%(cluster_name)s-hadoop-mgr-3:8188",
                    "yarn.timeline-service.webapp.https.address" : "%(cluster_name)s-hadoop-mgr-3:8190",
                    "yarn.timeline-service.leveldb-timeline-store.path" : "/mnt/hadoop/yarn/timeline"
                }
            }
        },
        {
            "capacity-scheduler" : {
                "properties" : {
                  "yarn.scheduler.capacity.maximum-am-resource-percent" : "0.5",
                  "yarn.scheduler.capacity.maximum-applications" : "10000",
                  "yarn.scheduler.capacity.node-locality-delay" : "40",
                  "yarn.scheduler.capacity.resource-calculator" : "org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator",
                  "yarn.scheduler.capacity.queue-mappings-override.enable" : "false",
                  "yarn.scheduler.capacity.root.acl_administer_queue" : "pnda ",
                  "yarn.scheduler.capacity.root.acl_submit_applications" : "pnda ",
                  "yarn.scheduler.capacity.root.capacity" : "100",
                  "yarn.scheduler.capacity.root.queues" : "applications,default",
                  "yarn.scheduler.capacity.root.priority" : "0",
                  "yarn.scheduler.capacity.root.accessible-node-labels" : "*",
                  "yarn.scheduler.capacity.root.default.maximum-applications" : "10000",
                  "yarn.scheduler.capacity.root.default.acl_submit_applications" : "*",
                  "yarn.scheduler.capacity.root.default.maximum-capacity" : "100",
                  "yarn.scheduler.capacity.root.default.user-limit-factor" : "1",
                  "yarn.scheduler.capacity.root.default.state" : "RUNNING",
                  "yarn.scheduler.capacity.root.default.capacity" : "99",
                  "yarn.scheduler.capacity.root.default.ordering-policy" : "fair",
                  "yarn.scheduler.capacity.root.default.ordering-policy.fair.enable-size-based-weight" : "false",
                  "yarn.scheduler.capacity.root.default.priority" : "0",
                  "yarn.scheduler.capacity.root.applications.acl_administer_queue" : "*",
                  "yarn.scheduler.capacity.root.applications.acl_submit_applications" : "*",
                  "yarn.scheduler.capacity.root.applications.minimum-user-limit-percent" : "100",
                  "yarn.scheduler.capacity.root.applications.maximum-capacity" : "100",
                  "yarn.scheduler.capacity.root.applications.state" : "RUNNING",
                  "yarn.scheduler.capacity.root.applications.capacity" : "1",
                  "yarn.scheduler.capacity.root.applications.queues" : "dev,prod",
                  "yarn.scheduler.capacity.root.applications.priority" : "0",
                  "yarn.scheduler.capacity.root.applications.dev.maximum-applications" : "100000000",
                  "yarn.scheduler.capacity.root.applications.dev.acl_administer_queue" : " dev,prod",
                  "yarn.scheduler.capacity.root.applications.dev.acl_submit_applications" : " dev,prod",
                  "yarn.scheduler.capacity.root.applications.dev.minimum-user-limit-percent" : "100",
                  "yarn.scheduler.capacity.root.applications.dev.maximum-capacity" : "100",
                  "yarn.scheduler.capacity.root.applications.dev.user-limit-factor" : "10000",
                  "yarn.scheduler.capacity.root.applications.dev.state" : "RUNNING",
                  "yarn.scheduler.capacity.root.applications.dev.capacity" : "1",
                  "yarn.scheduler.capacity.root.applications.dev.ordering-policy" : "fair",
                  "yarn.scheduler.capacity.root.applications.dev.ordering-policy.fair.enable-size-based-weight" : "false",
                  "yarn.scheduler.capacity.root.applications.dev.priority" : "0",
                  "yarn.scheduler.capacity.root.applications.prod.maximum-applications" : "1000000",
                  "yarn.scheduler.capacity.root.applications.prod.acl_administer_queue" : " prod",
                  "yarn.scheduler.capacity.root.applications.prod.acl_submit_applications" : " prod",
                  "yarn.scheduler.capacity.root.applications.prod.minimum-user-limit-percent" : "100",
                  "yarn.scheduler.capacity.root.applications.prod.maximum-capacity" : "100",
                  "yarn.scheduler.capacity.root.applications.prod.user-limit-factor" : "100",
                  "yarn.scheduler.capacity.root.applications.prod.state" : "RUNNING",
                  "yarn.scheduler.capacity.root.applications.prod.capacity" : "99",
                  "yarn.scheduler.capacity.root.applications.prod.ordering-policy" : "fair",
                  "yarn.scheduler.capacity.root.applications.prod.ordering-policy.fair.enable-size-based-weight" : "false",
                  "yarn.scheduler.capacity.root.applications.prod.priority" : "0"
                }
            }
        },
        {
            "mapred-site" : {
                "properties" : {
                    "mapred_log_dir_prefix" : "/var/log/pnda/hadoop-mapreduce"
                }
            }
        },
        {
            "mapred-env":{
                "properties": {
                    "jobhistory_heapsize": "8192"
                }
            }
        },
        {
            "zookeeper-env" : {
                "properties" : {
                    "zk_log_dir" : "/var/log/pnda/zookeeper",
                    "zk_server_heapsize" : "2048"
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
                    "oozie_data_dir" : "/mnt/hadoop/oozie/data",
                    "oozie_user" : "oozie",
                    "oozie_admin_users" : "{oozie_user}, oozie-admin",
                    "oozie_database" : "Existing MySQL / MariaDB Database",
                    "oozie_heapsize": "4096m"
                }
            }
        },
        {
            "oozie-site" : {
                "properties" : {
                    "oozie.service.JPAService.jdbc.password" : "oozie",
                    "oozie.service.JPAService.jdbc.username" : "oozie",
                    "oozie.service.JPAService.jdbc.url" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-4/oozie",
                    "oozie.service.JPAService.jdbc.driver" : "com.mysql.jdbc.Driver",
                    "oozie.authentication.type" : "simple",
                    "oozie.db.schema.name" : "oozie"
                }
            }
        },
        {
            "hive-env" : {
                "properties" : {
                    "hive_ambari_database" : "MySQL",
                    "hive_ambari_host" : "%(cluster_name)s-hadoop-mgr-4",
                    "hive_database" : "MySQL Database",
                    "hive_database_name" : "hive",
                    "hive_database_type" : "mysql",
                    "hive_existing_mssql_server_2_host" : "%(cluster_name)s-hadoop-mgr-4",
                    "hive_existing_mssql_server_host" : "%(cluster_name)s-hadoop-mgr-4",
                    "hive_existing_mysql_host" : "%(cluster_name)s-hadoop-mgr-4",
                    "hive_hostname" : "%(cluster_name)s-hadoop-mgr-4",
                    "hive_user" : "hive",
                    "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                    "javax.jdo.option.ConnectionPassword" : "hive",
                    "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-4/hive",
                    "javax.jdo.option.ConnectionUserName" : "hive",
                    "hive_log_dir" : "/var/log/pnda/hive",
                    "hcat_log_dir" : "/var/log/pnda/webhcat",
                    "hive.client.heapsize": "4096",
                    "hive.heapsize": "16384",
                    "hive.metastore.heapsize": "16384"
                }
            }
        },
        {
            "hive-interactive-env": {
                "properties": {
                    "hive_heapsize": "16384"
                }
            }
        },
        {
            "hive-site" : {
                "properties" : {
                    "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                    "javax.jdo.option.ConnectionPassword" : "hive",
                    "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-4/hive?createDatabaseIfNotExist=true",
                    "javax.jdo.option.ConnectionUserName" : "hive"
                }
            }
        },
        {
            "hbase-site" : {
                "properties" : {
                    "zookeeper.session.timeout" : "300000",
                    "hbase.tmp.dir" : "/mnt/hadoop/hbase/tmp",
                    "hbase.rootdir" : "hdfs://HDFS-HA:8020/apps/hbase/data"
                }
            }
        },
        {
            "hbase-env" : {
                "properties" : {
                    "hbase_master_heapsize" : "8192m",
                    "hbase_log_dir" : "/var/log/pnda/hbase"
                }
            }
        },
        {
            "hadoop-env" : {
                "properties" : {
                    "namenode_heapsize": "16384m",
                    "namenode_opt_maxnewsize": "2048m",
                    "namenode_opt_newsize": "2048m",
                    "namenode_opt_permsize": "128m",
                    "namenode_opt_maxpermsize": "256m",
                    "hdfs_log_dir_prefix": "/var/log/pnda/hadoop",
                    "hadoop_heapsize": "2048",
                    "dtnode_heapsize" : "2048m"
                }
            }
        },
        {
            "hdfs-site" : {
                "properties" : {
                    "dfs.replication" : "3",
                    "dfs.replication.max" : "50",
                    "dfs.datanode.data.dir" : "{{ data_volumes }}",
                    "dfs.client.failover.proxy.provider.HDFS-HA" : "org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider",
                    "dfs.ha.automatic-failover.enabled" : "true",
                    "dfs.ha.fencing.methods" : "shell(/bin/true)",
                    "dfs.ha.namenodes.HDFS-HA" : "nn1,nn2",
                    "dfs.journalnode.edits.dir" : "/mnt/hadoop/hdfs/jn",
                    "dfs.namenode.http-address" : "%(cluster_name)s-hadoop-mgr-1:50070",
                    "dfs.namenode.http-address.HDFS-HA.nn1" : "%(cluster_name)s-hadoop-mgr-1:50070",
                    "dfs.namenode.http-address.HDFS-HA.nn2" : "%(cluster_name)s-hadoop-mgr-2:50070",
                    "dfs.namenode.https-address" : "%(cluster_name)s-hadoop-mgr-1:50470",
                    "dfs.namenode.https-address.HDFS-HA.nn1" : "%(cluster_name)s-hadoop-mgr-1:50470",
                    "dfs.namenode.https-address.HDFS-HA.nn2" : "%(cluster_name)s-hadoop-mgr-2:50470",
                    "dfs.namenode.rpc-address.HDFS-HA.nn1" : "%(cluster_name)s-hadoop-mgr-1:8020",
                    "dfs.namenode.rpc-address.HDFS-HA.nn2" : "%(cluster_name)s-hadoop-mgr-2:8020",
                    "dfs.namenode.shared.edits.dir" : "qjournal://%(cluster_name)s-hadoop-mgr-1:8485;%(cluster_name)s-hadoop-mgr-2:8485;%(cluster_name)s-hadoop-mgr-4:8485/HDFS-HA",
                    "dfs.nameservices" : "HDFS-HA",
                    "dfs.namenode.checkpoint.dir" : "/mnt/hadoop/hdfs/snn",
                    "dfs.namenode.name.dir" : "/mnt/hadoop/hdfs/nn"
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
                    "fs.defaultFS" : "hdfs://HDFS-HA",
                    "ha.zookeeper.quorum" : "%(cluster_name)s-hadoop-mgr-1:2181,%(cluster_name)s-hadoop-mgr-2:2181,%(cluster_name)s-hadoop-mgr-4:2181",
                    "ha.failover-controller.active-standby-elector.zk.op.retries" : "120",
                    "hadoop.http.authentication.simple.anonymous.allowed" : "true",
                    "hadoop.proxyuser.hcat.groups" : "users",
                    "hadoop.proxyuser.hcat.hosts" : "*",
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
                    "hadoop.proxyuser.oozie.hosts" : "*",
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
                "name" : "RESOURCEMANAGER"
                },
                {
                "name" : "NAMENODE"
                },
                {
                "name" : "JOURNALNODE"
                },
                {
                "name" : "ZKFC"
                },
                {
                "name" : "HBASE_MASTER"
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
            "name" : "MGR02",
            "components" : [
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "ZOOKEEPER_SERVER"
                },
                {
                "name" : "RESOURCEMANAGER"
                },
                {
                "name" : "NAMENODE"
                },
                {
                "name" : "JOURNALNODE"
                },
                {
                "name" : "ZKFC"
                },
                {
                "name" : "HBASE_MASTER"
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
            "name" : "MGR03",
            "components" : [
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "HIVE_SERVER"
                },
                {
                "name" : "HIVE_METASTORE"
                },
                {
                "name" : "APP_TIMELINE_SERVER"
                },
                {
                "name" : "WEBHCAT_SERVER"
                },
                {
                "name" : "HBASE_CLIENT"
                }
            ],
            "cardinality" : "1"
        },
        {
            "name" : "MGR04",
            "components" : [
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "OOZIE_SERVER"
                },
                {
                "name" : "ZOOKEEPER_SERVER"
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
                "name" : "JOURNALNODE"
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
                "name" : "SPARK_CLIENT"
                }
            ],
            "cardinality" : "1+"
        },
        {
            "name" : "CM",
            "components" : [
                {
                "name" : "METRICS_COLLECTOR"
                },
                {
                "name" : "METRICS_MONITOR"
                },
                {
                "name" : "ZOOKEEPER_CLIENT"
                },
                {
                "name" : "HBASE_CLIENT"
                },
                {
                "name" : "HDFS_CLIENT"
                },
                {
                "name" : "SPARK_CLIENT"
                },
                {
                "name" : "SPARK_CLIENT"
                }
            ],
            "cardinality" : "1"
        }
    ],
    "Blueprints" : {
        "blueprint_name" : "pnda-blueprint",
        "stack_name" : "HDP",
        "stack_version" : "2.6"
    }
}'''
