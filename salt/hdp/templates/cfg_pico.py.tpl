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
                "properties" : {
                    "metrics_monitor_log_dir" : "/var/log/pnda/ambari-metrics-monitor",
                    "metrics_collector_log_dir" : "/var/log/pnda/ambari-metrics-collector"
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
{% raw %}
                    "content" : "\n#!/usr/bin/env bash\n\n# This file is sourced when running various Spark programs.\n# Copy it as spark-env.sh and edit that to configure Spark for your site.\n\n# Options read in YARN client mode\n#SPARK_EXECUTOR_INSTANCES=\"2\" #Number of workers to start (Default: 2)\nSPARK_EXECUTOR_CORES=\"1\" #Number of cores for the workers (Default: 1).\nSPARK_EXECUTOR_MEMORY=\"512M\" #Memory per Worker (e.g. 1000M, 2G) (Default: 1G)\nSPARK_DRIVER_MEMORY=\"512M\" #Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)\n#SPARK_YARN_APP_NAME=\"spark\" #The name of your application (Default: Spark)\n#SPARK_YARN_QUEUE=\"~@~Xdefault~@~Y\" #The hadoop queue to use for allocation requests (Default: @~Xdefault~@~Y)\n#SPARK_YARN_DIST_FILES=\"\" #Comma separated list of files to be distributed with the job.\n#SPARK_YARN_DIST_ARCHIVES=\"\" #Comma separated list of archives to be distributed with the job.\n\n# Generic options for the daemons used in the standalone deploy mode\n\n# Alternate conf dir. (Default: ${SPARK_HOME}/conf)\nexport SPARK_CONF_DIR=${SPARK_CONF_DIR:-{{spark_home}}/conf}\n\n# Where log files are stored.(Default:${SPARK_HOME}/logs)\n#export SPARK_LOG_DIR=${SPARK_HOME:-{{spark_home}}}/logs\nexport SPARK_LOG_DIR={{spark_log_dir}}\n\n# Where the pid file is stored. (Default: /tmp)\nexport SPARK_PID_DIR={{spark_pid_dir}}\n\n# A string representing this instance of spark.(Default: $USER)\nSPARK_IDENT_STRING=$USER\n\n# The scheduling priority for daemons. (Default: 0)\nSPARK_NICENESS=0\n\nexport HADOOP_HOME=${HADOOP_HOME:-{{hadoop_home}}}\nexport HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-{{hadoop_conf_dir}}}\n\n# The java implementation to use.\nexport JAVA_HOME={{java_home}}\n\n#Memory for Master, Worker and history server (default: 1024MB)\nexport SPARK_DAEMON_MEMORY={{spark_daemon_memory}}m\n\nif [ -d \"/etc/tez/conf/\" ]; then\n  export TEZ_CONF_DIR=/etc/tez/conf\nelse\n  export TEZ_CONF_DIR=\nfi"
{% endraw %}
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
                    "yarn.nodemanager.resource.cpu-vcores" : "8",
                    "yarn.nodemanager.resource.memory-mb" : "4096",
                    "yarn.log-aggregation.retain-seconds" : "7200",
                    "yarn.scheduler.minimum-allocation-vcores" : "1",
                    "yarn.scheduler.minimum-allocation-mb" : "256",
                    "yarn.scheduler.maximum-allocation-mb" : "4096",
                    "yarn.scheduler.maximum-allocation-vcores" : "8"
                }
            }
        },
        {
            "capacity-scheduler" : {
                "properties" : {
                    "yarn.scheduler.capacity.maximum-am-resource-percent" : "1.0"
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
            "zoo.cfg" : {
                "properties" : {
                    "dataDir" : "/data0/zookeeper"
                }
            }
        },
        {
            "oozie-env" : {
                    "properties" : {
                    "oozie_log_dir" : "/var/log/pnda/oozie",
                    "oozie_data_dir" : "/data0/var/lib/oozie/data",
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
                    "oozie.service.JPAService.jdbc.url" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-1/oozie",
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
                    "hive_ambari_host" : "%(cluster_name)s-hadoop-mgr-1",
                    "hive_database" : "MySQL Database",
                    "hive_database_name" : "hive",
                    "hive_database_type" : "mysql",
                    "hive_existing_mssql_server_2_host" : "%(cluster_name)s-hadoop-mgr-1",
                    "hive_existing_mssql_server_host" : "%(cluster_name)s-hadoop-mgr-1",
                    "hive_existing_mysql_host" : "%(cluster_name)s-hadoop-mgr-1",
                    "hive_hostname" : "%(cluster_name)s-hadoop-mgr-1",
                    "hive_user" : "hive",
                    "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                    "javax.jdo.option.ConnectionPassword" : "hive",
                    "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-1/hive",
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
                    "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(cluster_name)s-hadoop-mgr-1/hive?createDatabaseIfNotExist=true",
                    "javax.jdo.option.ConnectionUserName" : "hive"
                }
            }
        },
        {
            "hbase-site" : {
                "properties" : {
                    "zookeeper.session.timeout" : "300000"
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
                    "dfs.datanode.data.dir" : "/data0/dn"
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
                    "fs.defaultFS" : "hdfs://%(cluster_name)s-hadoop-mgr-1:8020",
                    "fs.trash.interval" : "360",
                    "ha.failover-controller.active-standby-elector.zk.op.retries" : "120",
                    "hadoop.http.authentication.simple.anonymous.allowed" : "true",
                    "hadoop.proxyuser.hcat.groups" : "users",
                    "hadoop.proxyuser.hcat.hosts" : "%(cluster_name)s-hadoop-mgr-1",
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
                    "hadoop.proxyuser.oozie.hosts" : "%(cluster_name)s-hadoop-mgr-1",
                    "hadoop.security.auth_to_local" : "DEFAULT",
                    "hadoop.security.authentication" : "simple",
                    "hadoop.security.authorization" : "false",
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