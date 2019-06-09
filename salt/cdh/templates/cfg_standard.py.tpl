"""
Name:       cfg_standard
Purpose:    Configuration for this particular flavor of PNDA

Author:     PNDA team

Created:    14/03/2016
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
          "config": {'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-alertpublisher'}},
         {"type": "EVENTSERVER",
          "config": {'eventserver_index_dir': '/mnt/cloudera-scm-eventserver',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-eventserver'}},
         {"type": "HOSTMONITOR",
          "config": {'firehose_storage_dir': '/mnt/cloudera-host-monitor',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose'}},
         {"type": "SERVICEMONITOR",
          "config": {'firehose_storage_dir': '/mnt/cloudera-service-monitor',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose'}}]
}

OOZIE_CFG = {"service": "OOZIE",
             "name": '{{ pillar['hadoop_services']['oozie_server']['service'] }}',
             "config": {'mapreduce_yarn_service': '{{ pillar['hadoop_services']['yarn_resource_manager']['service'] }}',
                        'zookeeper_service': '{{ pillar['hadoop_services']['zookeeper_server']['service'] }}'},
             "roles": [{"name": "oozie-s",
                        "type": "OOZIE_SERVER",
                        "target": "MGR04"}],
             "role_cfg": [{"type": "OOZIE_SERVER",
                           "config": {'oozie_data_dir': '/mnt/hadoop/oozie',
                                      'oozie_log_dir': '/var/log/pnda/oozie',
                                      'oozie_database_type': 'mysql',
                                      'oozie_database_host': '{{ mysql_host }}',
                                      'oozie_database_user': 'oozie',
                                      'oozie_database_password': 'oozie',
                                      'log_directory_free_space_absolute_thresholds': '{"warning": "1050000000","critical": "900000000"}'}}]}

ZK_CFG = {"service": "ZOOKEEPER",
          "name": '{{ pillar['hadoop_services']['zookeeper_server']['service'] }}',
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
                        "config": {'dataDir': '/mnt/hadoop/zookeeper',
                                   'dataLogDir': '/mnt/hadoop/zookeeper',
                                   'zk_server_log_dir': '/var/log/pnda/zookeeper',
                                   'log_directory_free_space_absolute_thresholds': '{"warning": "1050000000","critical": "900000000"}'}}]}

MAPRED_CFG = {
    "service": "YARN",
    "name": '{{ pillar['hadoop_services']['yarn_resource_manager']['service'] }}',
    "config": {'hdfs_service': '{{ pillar['hadoop_services']['hdfs_namenode']['service'] }}', 'zookeeper_service': '{{ pillar['hadoop_services']['zookeeper_server']['service'] }}', 'yarn_log_aggregation_retain_seconds': '265000', 'yarn_log_aggregation_enable': 'false'},
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
            "config": {'mapred_reduce_tasks': 4, 'mapred_submit_replication': 1}
        },
        {
            "type": "NODEMANAGER",
            "config":
                {
                    'yarn_nodemanager_heartbeat_interval_ms': 100,
                    'yarn_nodemanager_local_dirs': '/mnt/hadoop/yarn/nm',
                    'yarn_nodemanager_log_dirs': '/var/log/pnda/hadoop-yarn/container',
                    'node_manager_log_dir': '/var/log/pnda/hadoop-yarn',
                    'yarn_nodemanager_resource_cpu_vcores': '7',
                    'yarn_nodemanager_resource_memory_mb': '14336'
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
                    'resourcemanager_fair_scheduler_configuration': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?> <allocations> <queue name="root"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> </aclSubmitApps> <aclAdministerApps>pnda </aclAdministerApps><queue name="default"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps>pnda </aclSubmitApps> </queue> <queue name="applications" type="parent"> <weight>0.0</weight> <schedulingPolicy>fair</schedulingPolicy> <queue name="dev"> <weight>0.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> dev,prod</aclSubmitApps> </queue> <queue name="prod"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> prod</aclSubmitApps> </queue> </queue> </queue> <defaultQueueSchedulingPolicy>fair</defaultQueueSchedulingPolicy> <queuePlacementPolicy> <rule name="specified" create="false"/> <rule name="default"/> </queuePlacementPolicy> </allocations>'
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
    "name": '{{ pillar['hadoop_services']['hdfs_namenode']['service'] }}',
    "config":
        {
            'dfs_replication': 2,
            'core_site_safety_valve':
                ('<property> <name>hadoop.tmp.dir</name><value>/mnt/hadoop-tmp/${user.name}</value></property>\r\n\r\n'
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
                "config": {'dfs_name_dir_list': '/mnt/hadoop/hdfs/nn',
                           'dfs_namenode_handler_count': 60,
                           'dfs_namenode_service_handler_count': 60,
                           'namenode_log_dir': '/var/log/pnda/hadoop/nn',
                           'namenode_java_heapsize': 3221225472,
                           'dfs_qjournal_write_txns_timeout_ms': 120000}
            },
            {
                "type": "DATANODE",
                "config": {'dfs_data_dir_list': '{{ data_volumes }}', 'datanode_log_dir': '/var/log/pnda/hadoop/dn'}
            },
            {
                "type": "JOURNALNODE",
                "config": {'dfs_journalnode_edits_dir':'/mnt/hadoop/hdfs/jn', 'journalnode_log_dir': '/var/log/pnda/hadoop/jn'}
            },
            {
                "type": "SECONDARYNAMENODE",
                "config": {'fs_checkpoint_dir_list': '/mnt/hadoop/hdfs/snn',
                           'secondarynamenode_log_dir': '/var/log/pnda/hadoop/snn',
                           'secondary_namenode_java_heapsize': 3221225472}
            },
            {
                "type": "FAILOVERCONTROLLER",
                "config": {'failover_controller_log_dir': '/var/log/pnda/hadoop/fc'}
            },
            {
                "type": "GATEWAY",
                "config": {}
            },
            {
                "type": "HTTPFS",
                "config": {'httpfs_log_dir': '/var/log/pnda/hadoop-httpfs'}
            }
        ]
}

HBASE_CFG = {
    "service": "HBASE",
    "name": '{{ pillar['hadoop_services']['hbase_master']['service'] }}',
    "config": {'hdfs_service': '{{ pillar['hadoop_services']['hdfs_namenode']['service'] }}', 'zookeeper_service': '{{ pillar['hadoop_services']['zookeeper_server']['service'] }}'},
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
            "config": {'hbase_restserver_log_dir': '/var/log/pnda/hbase'}
        },
        {
            "type": "HBASETHRIFTSERVER",
            "config": {'hbase_thriftserver_log_dir': '/var/log/pnda/hbase'}
        },
        {
            "type": "MASTER",
            "config": {'hbase_master_log_dir': '/var/log/pnda/hbase', 'hbase_master_java_heapsize': '8589934592'}
        },
        {
            "type": "REGIONSERVER",
            "config": {'hbase_regionserver_log_dir': '/var/log/pnda/hbase'}
        },
        {
            "type": "GATEWAY",
            "config": {}
        }
    ]
}

HIVE_CFG = {
    "service": "HIVE",
    "name": '{{ pillar['hadoop_services']['hive_server']['service'] }}',
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
                "config": {'hive_log_dir': '/var/log/pnda/hive'}
            },
            {
                "type": "HIVESERVER2",
                "config": {'hive_log_dir': '/var/log/pnda/hive', 'hiveserver2_java_heapsize': '1073741824'}
            },
            {
                "type": "GATEWAY",
                "config": {}
            }
        ]
}

IMPALA_CFG = {
    "service": "IMPALA",
    "name": '{{ pillar['hadoop_services']['impala_catalog_server']['service'] }}',
    "config": {
        'hbase_service': HBASE_CFG['name'],
        'hive_service': HIVE_CFG['name'],
        'hdfs_service': HDFS_CFG['name'],
        'rm_dirty': True
    },
    'roles': [
        {'name': 'impala-CATALOGSERVER', 'type': 'CATALOGSERVER', 'target': 'MGR03'},
        {'name': 'impala-IMPALAD', 'type': 'IMPALAD', 'target': 'DATANODE'},
        {'name': 'impala-STATESTORE', 'type': 'STATESTORE', 'target': 'MGR03'}
    ],
    'role_cfg': [
        {'type': 'IMPALAD', 'config': {'impalad_memory_limit': '5731516416',
                                       'scratch_dirs': '/impala/impalad',
                                       'log_dir': '/var/log/pnda/impala'}},
        {'type': 'CATALOGSERVER', 'config': {'log_dir': '/var/log/pnda/impala'}},
        {'type': 'STATESTORE', 'config': {'log_dir': '/var/log/pnda/impala'}},
        {'type': 'LLAMA', 'config': {'llama_log_dir': '/var/log/pnda/impala-llama'}}
    ]
}

HUE_CFG = {
    "service": "HUE",
    "name": '{{ pillar['hadoop_services']['hue_server']['service'] }}',
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
    'name': '{{ pillar['hadoop_services']['spark_job_histroy_server']['service'] }}',
    'config': {
        'yarn_service': MAPRED_CFG['name'],
        'spark-conf/spark-env.sh_service_safety_valve':"SPARK_PYTHON_PATH={{ app_packages_dir }}/lib/python2.7/site-packages\nexport PYSPARK_DRIVER_PYTHON=/opt/pnda/anaconda/bin/python\nexport PYSPARK_PYTHON=/opt/pnda/anaconda/bin/python\nexport PYTHONPATH=\"$PYTHONPATH:$SPARK_PYTHON_PATH\""
    },
    'roles': [
        {'name': 'spark', 'type': 'SPARK_YARN_HISTORY_SERVER', 'target': 'MGR03'},
        {'name': 'spark_gw1', 'type': 'GATEWAY', 'target': 'EDGE'},
        {'name': 'spark_gw2', 'type': 'GATEWAY', 'target': 'DATANODE'}
    ],
    'role_cfg': [
        {'type': 'SPARK_YARN_HISTORY_SERVER', 'config': {}},
        {'type': 'GATEWAY', 'config': {
            'spark_history_enabled': 'false',
            'spark-conf/spark-defaults.conf_client_config_safety_valve': 'spark.metrics.conf.*.sink.graphite.class=org.apache.spark.metrics.sink.GraphiteSink\nspark.metrics.conf.*.sink.graphite.host={{ pnda_graphite_host }}\nspark.metrics.conf.*.sink.graphite.port=2003\nspark.metrics.conf.*.sink.graphite.period=60\nspark.metrics.conf.*.sink.graphite.prefix=spark\nspark.metrics.conf.*.sink.graphite.unit=seconds\nspark.metrics.conf.master.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.metrics.conf.worker.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.metrics.conf.driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.metrics.conf.executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.yarn.appMasterEnv.PYSPARK_PYTHON=/opt/pnda/anaconda/bin/python\nspark.yarn.appMasterEnv.PYSPARK_DRIVER_PYTHON=/opt/pnda/anaconda/bin/python'}}
    ]
}
