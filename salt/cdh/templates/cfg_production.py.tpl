"""
Name:       cfg_production
Purpose:    Configuration for this particular flavor of PNDA

"""

isHA_enabled = True

CM_CFG = {
    "hosts_config": {
        'host_agent_parcel_directory_free_space_absolute_thresholds': '{"warning":"-2.0","critical":"6000000000"}',
        'memory_overcommit_threshold': '0.85'
    }
}

CMS_CFG = {
    "service": "MGMT",
    "name": "mgmt",
    "roles": [
        {"name": "cms-ap",
         "type": "ALERTPUBLISHER",
         "target": "CM"},
        {"name": "cms-es",
         "type": "EVENTSERVER",
         "target": "CM"},
        {"name": "cms-hm",
         "type": "HOSTMONITOR",
         "target": "CM"},
        {"name": "cms-sm",
         "type": "SERVICEMONITOR",
         "target": "CM"}
     ],
     "role_cfg": [
         {"type": "ACTIVITYMONITOR",
          "config": {'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose'}},
         {"type": "ALERTPUBLISHER",
          "config": {'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-alertpublisher',
                     "alert_heapsize": "1073741824"}},
         {"type": "EVENTSERVER",
          "config": {'eventserver_index_dir': '/mnt/var/lib/cloudera-scm-eventserver',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-eventserver',
                     "event_server_heapsize": "2147483648"}},
         {"type": "HOSTMONITOR",
          "config": {'firehose_storage_dir': '/mnt/var/lib/cloudera-host-monitor',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose',
                     "firehose_heapsize":"2147483648"}},
         {"type": "SERVICEMONITOR",
          "config": {'firehose_storage_dir': '/mnt/var/lib/cloudera-service-monitor',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose',
                     "firehose_heapsize": "2147483648"}}]
}

OOZIE_CFG = {"service": "OOZIE",
             "name": "oozie01",
             "config": {'mapreduce_yarn_service': 'yarn01',
                        'zookeeper_service': 'zk01'},
             "roles": [{"name": "oozie-s",
                        "type": "OOZIE_SERVER",
                        "target": "MGR04"}],
             "role_cfg": [{"type": "OOZIE_SERVER",
                           "config": {'oozie_data_dir': '/mnt/var/lib/oozie/data',
                                      'oozie_log_dir': '/var/log/pnda/oozie',
                                      'oozie_database_type': 'mysql',
                                      'oozie_database_host': '{{ mysql_host }}',
                                      'oozie_database_user': 'oozie',
                                      'oozie_database_password': 'oozie',
                                      'oozie_java_heapsize':"4294967296",
                                      'log_directory_free_space_absolute_thresholds': '{"warning": "1050000000","critical": "900000000"}'}}]}

ZK_CFG = {"service": "ZOOKEEPER",
          "name": "zk01",
          "config": {'zookeeper_datadir_autocreate': 'true'},
          "roles": [{"name": "zk-s",
                     "type": "SERVER",
                     "target": "MGR02"},
                    {"name": "zk-s",
                     "type": "SERVER",
                     "target": "MGR01"},
                    {"name": "zk-s",
                     "type": "SERVER",
                     "target": "MGR04"}],
          "role_cfg": [{"type": "SERVER",
                        "config": {'dataDir': '/mnt/var/lib/zookeeper',
                                   'dataLogDir': '/mnt/var/lib/zookeeper',
                                   'zk_server_log_dir': '/var/log/pnda/zookeeper',
                                   'log_directory_free_space_absolute_thresholds': '{"warning": "1050000000","critical": "900000000"}',
                                   'zookeeper_server_java_heapsize': "4294967296"
                                   }}]}




MAPRED_CFG = {
    "service": "YARN",
    "name": "yarn01",
    "config": {'hdfs_service': 'hdfs01', 'zookeeper_service': 'zk01', 'yarn_log_aggregation_retain_seconds': '265000', 'yarn_log_aggregation_enable': 'false'},
    "roles": [
        {
            "name": "yarn-jh",
            "type": "JOBHISTORY",
            "target": "MGR04"
        },
        {
            "name": "yarn-rm",
            "type": "RESOURCEMANAGER",
            "target": "MGR01"
        },
        {
            "name": "yarn-rm2",
            "type": "RESOURCEMANAGER",
            "target": "MGR02"
        },
        {
            "name": "yarn-nm",
            "type": "NODEMANAGER",
            "target": "DATANODE"
        },
        {
            "name": "yarn-gw",
            "type": "GATEWAY",
            "target": "EDGE"
        }
    ],
    "role_cfg": [
        {
            "type": "GATEWAY",
            "config": {'mapred_reduce_tasks': 12,
                       'mapred_submit_replication': 3,
                       "mapreduce_client_java_heapsize": "2147483648",
                       'mapreduce_map_memory_mb': '2048',
                       "mapreduce_map_java_opts_max_heap": "1717986918",
                       'mapreduce_reduce_memory_mb': '2048',
                       'mapreduce_reduce_java_opts_max_heap': '1717986918',
                       'yarn_app_mapreduce_am_resource_mb': '1024',
                       'yarn_app_mapreduce_am_max_heap': '858993459'
                       }
        },
        {
            "type": "NODEMANAGER",
            "config":
                {
                    'yarn_nodemanager_heartbeat_interval_ms': 100,
                    'yarn_nodemanager_local_dirs': '/mnt/yarn/nm',
                    'yarn_nodemanager_log_dirs': '/var/log/pnda/hadoop-yarn/container',
                    'node_manager_log_dir': '/var/log/pnda/hadoop-yarn',
                    'yarn_nodemanager_resource_cpu_vcores': '48',
                    'yarn_nodemanager_resource_memory_mb': '78848',
                    "node_manager_java_heapsize": "4294967296"
                }
        },
        {
            "type": "JOBHISTORY",
            "config":
                {
                    'mr2_jobhistory_log_dir': '/var/log/pnda/hadoop-mapreduce',
                    'mapreduce_jobhistory_max_age_ms': '265000000',
                    'mr2_jobhistory_java_heapsize': '8589934592'
                }
        },
        {
            "type": "RESOURCEMANAGER",
            "config":
                {
                    'resourcemanager_config_safety_valve':
                        '<property> \r\n<name>yarn.resourcemanager.proxy-user-privileges.enabled</name>\r\n<value>true</value>\r\n</property>',
                    'resource_manager_java_heapsize': '4294967296',
                    'resource_manager_log_dir': '/var/log/pnda/hadoop-yarn',
                    'resourcemanager_fair_scheduler_configuration': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?> <allocations> <queue name="root"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> </aclSubmitApps> <aclAdministerApps>pnda </aclAdministerApps><queue name="default"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps>pnda </aclSubmitApps> </queue> <queue name="applications" type="parent"> <weight>0.0</weight> <schedulingPolicy>fair</schedulingPolicy> <queue name="dev"> <weight>0.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> dev,prod</aclSubmitApps> </queue> <queue name="prod"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> prod</aclSubmitApps> </queue> </queue> </queue> <defaultQueueSchedulingPolicy>fair</defaultQueueSchedulingPolicy> <queuePlacementPolicy> <rule name="specified" create="false"/> <rule name="default"/> </queuePlacementPolicy> </allocations>',
                    'yarn_scheduler_increment_allocation_mb': '1024',
                    'yarn_scheduler_maximum_allocation_mb': '65536',
                    'yarn_scheduler_maximum_allocation_vcores': '48',
                    'yarn_scheduler_minimum_allocation_vcores': '1',
                    'yarn_scheduler_minimum_allocation_mb': '1024'
                }
        }
    ]
}

SWIFT_CONFIG = """\r\n<property><name>fs.swift.impl</name><value>org.apache.hadoop.fs.swift.snative.SwiftNativeFileSystem</value></property>
                  \r\n<property><name>fs.swift.service.pnda.auth.url</name><value>{{ keystone_auth_url }}</value></property>
                  \r\n<property><name>fs.swift.service.pnda.username</name><value>{{ keystone_user|e }}</value></property>
                  \r\n<property><name>fs.swift.service.pnda.tenant</name><value>{{ keystone_tenant|e }}</value></property>
                  \r\n<property><name>fs.swift.service.pnda.region</name><value>{{ region|e }}</value></property>
                  \r\n<property><name>fs.swift.service.pnda.public</name><value>true</value></property>
                  \r\n<property><name>fs.swift.service.pnda.password</name><value>{{ keystone_password|e }}</value></property>"""

S3_CONFIG = """\r\n<property><name>fs.s3a.access.key</name><value>{{ aws_key }}</value></property>
               \r\n<property><name>fs.s3a.secret.key</name><value>{{ aws_secret_key }}</value></property>"""

HDFS_CFG = {
    "service": "HDFS",
    "name": "hdfs01",
    "config":
        {
            'dfs_replication': 2,
            'core_site_safety_valve':
                ('<property> <name>hadoop.tmp.dir</name><value>/mnt/tmp/hadoop-${user.name}</value></property>\r\n\r\n'
                 '<property> \r\n<name>hadoop.proxyuser.yarn.hosts</name>\r\n<value>*</value>\r\n</property>\r\n\r\n'
                 '<property>\r\n<name>hadoop.proxyuser.yarn.groups</name>\r\n<value>*</value>\r\n</property>') + SWIFT_CONFIG + S3_CONFIG,
            'dfs_block_local_path_access_user': 'impala'
        },
    "roles":
        [
            {
                "name": "hdfs-nn",
                "type": "NAMENODE",
                "target": "MGR01"
            },
            {
                "name": "hdfs-snn",
                "type": "SECONDARYNAMENODE",
                "target": "MGR02"
            },
            {
                "name": "hdfs-jn1",
                "type": "JOURNALNODE",
                "target": "MGR01"
            },
            {
                "name": "hdfs-jn2",
                "type": "JOURNALNODE",
                "target": "MGR02"
            },
            {
                "name": "hdfs-jn3",
                "type": "JOURNALNODE",
                "target": "MGR04"
            },
            {
                "name": "hdfs-dn",
                "type": "DATANODE",
                "target": "DATANODE"
            },
            {
                "name": "hdfs-httpfs",
                "type": "HTTPFS",
                "target": "MGR03"
            },
            {
                "name": "hdfs-gw1",
                "type": "GATEWAY",
                "target": "EDGE"
            },
            {
                "name": "hdfs-gw2",
                "type": "GATEWAY",
                "target": "CM"
            }
        ],
    "role_cfg":
        [
            {
                "type": "NAMENODE",
                "config": {'dfs_name_dir_list': '/mnt/nn',
                           'dfs_namenode_handler_count': 60,
                           'dfs_namenode_service_handler_count': 60,
                           'namenode_log_dir': '/var/log/pnda/hadoop/nn',
                           'namenode_java_heapsize': 17179869184,
                           'dfs_qjournal_write_txns_timeout_ms': 120000}
            },
            {
                "type": "DATANODE",
                "config": {'dfs_data_dir_list': '{{ data_volumes }}',
                           'datanode_log_dir': '/var/log/pnda/hadoop/dn',
                           "datanode_java_heapsize": "2147483648"
                          }
            },
            {
                "type": "JOURNALNODE",
                "config": {'dfs_journalnode_edits_dir':'/mnt/jn/data',
                           'journalnode_log_dir': '/var/log/pnda/hadoop/jn',
                           'journalNode_java_heapsize':"2147483648"}
            },
            {
                "type": "SECONDARYNAMENODE",
                "config": {'fs_checkpoint_dir_list': '/mnt/snn',
                           'secondarynamenode_log_dir': '/var/log/pnda/hadoop/snn',
                           'secondary_namenode_java_heapsize': 17179869184}
            },
            {
                "type": "FAILOVERCONTROLLER",
                "config": {'failover_controller_log_dir': '/var/log/pnda/hadoop/fc',
                           "failover_controller_java_heapsize": "1073741824"
                }
            },
            {
                "type": "GATEWAY",
                "config": {"hdfs_client_java_heapsize": "1073741824",
                           "dfs_client_use_trash": "true"
                }
            },
            {
                "type": "HTTPFS",
                "config": {'httpfs_log_dir': '/var/log/pnda/hadoop-httpfs',
                           'httpfs_java_heapsize': "1073741824"}
            }
        ]
}

HBASE_CFG = {
    "service": "HBASE",
    "name": "hbase01",
    "config": {'hdfs_service': 'hdfs01', 'zookeeper_service': 'zk01'},
    "roles":
        [
            {
                "name": "master",
                "type": "MASTER",
                "target": "MGR01"
            },
            {
                "name": "master_sec",
                "type": "MASTER",
                "target": "MGR02"
            },
            {
                "name": "regionserver",
                "type": "REGIONSERVER",
                "target": "DATANODE"
            },
            {
                "name": "hbase-gw1",
                "type": "GATEWAY",
                "target": "EDGE"
            },
            {
                "name": "hbase-gw2",
                "type": "GATEWAY",
                "target": "CM"
            },
            {
                "name": "hbase-restserver",
                "type": "HBASERESTSERVER",
                "target": "MGR03"
            },
            {
                "name": "hbase-thriftserver",
                "type": "HBASETHRIFTSERVER",
                "target": "MGR03"
            }
        ],
    "role_cfg": [
        {
            "type": "HBASERESTSERVER",
            "config": {'hbase_restserver_log_dir': '/var/log/pnda/hbase',
                       'hbase_restserver_java_heapsize': "2147483648"
                      }
        },
        {
            "type": "HBASETHRIFTSERVER",
            "config": {'hbase_thriftserver_log_dir': '/var/log/pnda/hbase',
                       'hbase_thriftserver_java_heapsize':"2147483648"
                      }
        },
        {
            "type": "MASTER",
            "config": {'hbase_master_log_dir': '/var/log/pnda/hbase', 'hbase_master_java_heapsize': '8589934592'}
        },
        {
            "type": "REGIONSERVER",
            "config": {'hbase_regionserver_log_dir': '/var/log/pnda/hbase',
                       "hbase_regionserver_java_heapsize": "21474836480"
                      }
        },
        {
            "type": "GATEWAY",
            "config": {"hbase_client_java_heapsize": "1073741824"}
        }
    ]
}

HIVE_CFG = {
    "service": "HIVE",
    "name": "hive01",
    "config":
        {
            'hive_metastore_database_type': 'mysql',
            'hive_metastore_database_host': '{{ mysql_host }}',
            'hive_metastore_database_port': '3306',
            'hive_metastore_database_name': 'hive',
            'hive_metastore_database_password': 'hive',
            'hive_metastore_database_user': 'hive',
            'mapreduce_yarn_service': MAPRED_CFG['name'],
            'zookeeper_service': ZK_CFG['name']
        },
    "roles":
        [
            {
                "name": "hive-gw",
                "type": "GATEWAY",
                "target": "EDGE"
            },
            {
                "name": "hive-metastore",
                "type": "HIVEMETASTORE",
                "target": "MGR03"
            },
            {
                "name": "hive-server",
                "type": "HIVESERVER2",
                "target": "MGR03"
            }
        ],
    "role_cfg":
        [
            {
                "type": "HIVEMETASTORE",
                "config": {'hive_log_dir': '/var/log/pnda/hive',
                           "hive_metastore_java_heapsize":"17179869184"
                          }
            },
            {
                "type": "HIVESERVER2",
                "config": {'hive_log_dir': '/var/log/pnda/hive',
                           'hiveserver2_java_heapsize': '17179869184'
                          }
            },
            {
                "type": "GATEWAY",
                "config": {"hive_client_java_heapsize": "4294967296"}
            }
        ]
}

IMPALA_CFG = {
    "service": "IMPALA",
    "name": "impala01",
    "config": {
        'hbase_service': HBASE_CFG['name'],
        'hive_service': HIVE_CFG['name'],
        'hdfs_service': HDFS_CFG['name'],
        'rm_dirty': True
    },
    'roles': [
        {'name': 'impala-CATALOGSERVER', 'type': 'CATALOGSERVER', 'target': 'MGR04'},
        {'name': 'impala-IMPALAD', 'type': 'IMPALAD', 'target': 'DATANODE'},
        {'name': 'impala-STATESTORE', 'type': 'STATESTORE', 'target': 'MGR04'}
    ],
    'role_cfg': [
        {'type': 'IMPALAD', 'config': {'impalad_memory_limit': '5731516416',
                                       'scratch_dirs': '/impala/impalad',
                                       'log_dir': '/var/log/pnda/impala'}},
        {'type': 'CATALOGSERVER', 'config': {'log_dir': '/var/log/pnda/impala',
                                             "catalogd_embedded_jvm_heapsize":"8589934592"}},
        {'type': 'STATESTORE', 'config': {'log_dir': '/var/log/pnda/impala'}},
        {'type': 'LLAMA', 'config': {'llama_log_dir': '/var/log/pnda/impala-llama'}}
    ]
}

HUE_CFG = {
    "service": "HUE",
    "name": "hue01",
    "config":
        {
            'hbase_service': HBASE_CFG['name'],
            'hive_service': HIVE_CFG['name'],
            'oozie_service': OOZIE_CFG['name'],
            'zookeeper_service': ZK_CFG['name'],
            'impala_service': IMPALA_CFG['name'],
            'hue_webhdfs': 'localhost',
            'hue_service_safety_valve': '[hbase]\r\n hbase_clusters=(HBase|<hbase master IP address>:9090)',
            'time_zone': 'UTC',
            'database_host': '{{ mysql_host }}',
            'database_name': 'hue',
            'database_user': 'hue',
            'database_password': 'hue',
            'database_port': '3306',
            'database_type': 'mysql'
        },
    "roles":
        [
            {
                "name": "hue-server",
                "type": "HUE_SERVER",
                "target": "MGR04"
            }
        ],
    "role_cfg":
        [
            {
                "type": "HUE_SERVER",
                "config": {'hue_server_log_dir': '/var/log/pnda/hue', 'secret_key': 'Abcd1234'}
            }
        ]
}

SPARK_CFG = {
    'service': 'SPARK_ON_YARN',
    'name': 'spark_on_yarn',
    'config': {
        'yarn_service': MAPRED_CFG['name'],
        'spark-conf/spark-env.sh_service_safety_valve':"SPARK_PYTHON_PATH={{ app_packages_dir }}/lib/python2.7/site-packages\nexport PYTHONPATH=\"$PYTHONPATH:$SPARK_PYTHON_PATH\""
    },
    'roles': [
        {'name': 'spark', 'type': 'SPARK_YARN_HISTORY_SERVER', 'target': 'MGR04'},
        {'name': 'spark_gw1', 'type': 'GATEWAY', 'target': 'EDGE'},
        {'name': 'spark_gw2', 'type': 'GATEWAY', 'target': 'DATANODE'}
    ],
    'role_cfg': [
        {'type': 'SPARK_YARN_HISTORY_SERVER', 'config': {"history_server_max_heapsize": "4294967296"}},
        {'type': 'GATEWAY', 'config': {
            "spark_dynamic_allocation_cached_idle_timeout": "120"
            }
        }
    ]
}
