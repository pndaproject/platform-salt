"""
Name:       cfg_pico
Purpose:    Configuration for this particular flavor of PNDA

Author:     PNDA team

Created:    19/06/2017
"""
BLUEPRINT = '''{
    "configurations": [
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
                "javax.jdo.option.ConnectionUserName" : "hive"
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
            "hadoop-env" : {
                "properties" : {
                "dtnode_heapsize" : "2048m",
                "hadoop_heapsize" : "2048",
                "namenode_heapsize": "2048m",
                "namenode_opt_maxnewsize": "361m",
                "namenode_opt_newsize": "361m"
                }
            }
        },
        {
            "hdfs-site" : {
                "properties" : {
                    "dfs.replication" : "3",
                    "dfs.replication.max" : "50"
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
                "proxyuser_group" : "users"
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