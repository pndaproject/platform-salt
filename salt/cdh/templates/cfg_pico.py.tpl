"""
Name:       cfg_pico
Purpose:    Configuration for this particular flavor of PNDA

Author:     PNDA team

Created:    29/09/2016
"""

isHA_enabled = False

CM_CFG = {
    "hosts_config": {
        'host_agent_parcel_directory_free_space_absolute_thresholds': '{"warning":"never","critical":"never"}',
        'host_agent_log_directory_free_space_absolute_thresholds': '{"warning":209715200,"critical":104857600}',
        'memory_overcommit_threshold': '0.85'
    }
}

CMS_CFG = {
    "service": "MGMT",
    "name": "mgmt",
    "roles": [
        {"name": "cms-ap",
         "type": "ALERTPUBLISHER",
         "target": "EDGE"},
        {"name": "cms-es",
         "type": "EVENTSERVER",
         "target": "EDGE"},
        {"name": "cms-hm",
         "type": "HOSTMONITOR",
         "target": "EDGE"},
        {"name": "cms-sm",
         "type": "SERVICEMONITOR",
         "target": "EDGE"}
     ],
     "role_cfg": [
         {"type": "ACTIVITYMONITOR",
          "config": {'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose',
                     'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":3221225472}',
                     'max_log_backup_index': '2',
                     'max_log_size': '100',
                     'firehose_heapsize': '268435456'}},
         {"type": "ALERTPUBLISHER",
          "config": {'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-alertpublisher',
                     'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":3221225472}',
                     'max_log_backup_index': '2',
                     'max_log_size': '100'}},
         {"type": "EVENTSERVER",
          "config": {'eventserver_index_dir': '/data0/var/lib/cloudera-scm-eventserver',
                     'eventserver_index_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":3221225472}',
                     'max_log_backup_index': '2',
                     'max_log_size': '100',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-eventserver'}},
         {"type": "HOSTMONITOR",
          "config": {'firehose_storage_dir': '/data0/var/lib/cloudera-host-monitor',
                     'firehose_heapsize': '268435456',
                     'firehose_non_java_memory_bytes': '805306368',
                     'firehose_safety_valve': '<property>\n    <name>firehose_time_series_storage_bytes</name>\n    <value>524288000</value>\n</property>\n',
                     'firehose_storage_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":3221225472}',
                     'max_log_backup_index': '2',
                     'max_log_size': '100',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose'}},
         {"type": "SERVICEMONITOR",
          "config": {'firehose_storage_dir': '/data0/var/lib/cloudera-service-monitor',
                     'firehose_heapsize': '268435456',
                     'firehose_non_java_memory_bytes': '805306368',
                     'firehose_safety_valve': '<property>\n    <name>firehose_time_series_storage_bytes</name>\n    <value>524288000</value>\n</property>',
                     'firehose_storage_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                     'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":3221225472}',
                     'max_log_backup_index': '2',
                     'max_log_size': '100',
                     'mgmt_log_dir': '/var/log/pnda/cdh/cloudera-scm-firehose'}}]
}

OOZIE_CFG = {"service": "OOZIE",
             "name": "oozie01",
             "config": {'mapreduce_yarn_service': 'yarn01',
                        'zookeeper_service': 'zk01'},
             "roles": [{"name": "oozie-s",
                        "type": "OOZIE_SERVER",
                        "target": "MGR01"}],
             "role_cfg": [{"type": "OOZIE_SERVER",
                           "config": {'oozie_data_dir': '/data0/var/lib/oozie/data',
                                      'oozie_log_dir': '/var/log/pnda/oozie',
                                      'oozie_database_type': 'mysql',
                                      'oozie_database_host': '{{ mysql_host }}',
                                      'oozie_database_user': 'oozie',
                                      'oozie_database_password': 'oozie',
                                      'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                                      'log_directory_free_space_absolute_thresholds': '{"warning": "1050000000","critical": "900000000"}'}}]}

ZK_CFG = {"service": "ZOOKEEPER",
          "name": "zk01",
          "config": {'zookeeper_datadir_autocreate': 'true'},
          "roles": [{"name": "zk-s",
                     "type": "SERVER",
                     "target": "MGR01"}],
          "role_cfg": [{"type": "SERVER",
                        "config": {'dataDir': '/data0/var/lib/zookeeper',
                                   'dataLogDir': '/data0/var/lib/zookeeper',
                                   'zk_server_log_dir': '/var/log/pnda/zookeeper',
                                   'maxSessionTimeout': '60000',
                                   'log_directory_free_space_absolute_thresholds': '{"warning": "1050000000","critical": "900000000"}',
                                   'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                                   'max_log_backup_index': '2',
                                   'max_log_size': '100',
                                   'zookeeper_server_data_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                                   'zookeeper_server_data_log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}'}}]}

MAPRED_CFG = {
    "service": "YARN",
    "name": "yarn01",
    "config": {'hdfs_service': 'hdfs01', 'zookeeper_service': 'zk01', 'yarn_log_aggregation_retain_seconds': '86400', 'rm_dirty': 'true', 'yarn_log_aggregation_enable': 'false'},
    "roles": [
        {
            "name": "yarn-jh",
            "type": "JOBHISTORY",
            "target": "MGR01"
        },
        {
            "name": "yarn-rm",
            "type": "RESOURCEMANAGER",
            "target": "MGR01"
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
            "config": {'mapred_reduce_tasks': 3,
                       'mapred_submit_replication': 1,
                       'io_sort_mb': '128',
                       'mapreduce_client_java_heapsize': '321912832',
                       'mapreduce_map_java_opts_max_heap': '321912832',
                       'mapreduce_map_memory_mb': '384',
                       'mapreduce_reduce_java_opts_max_heap': '858783744',
                       'mapreduce_reduce_memory_mb': '1024',
                       'yarn_app_mapreduce_am_max_heap': '428867584',
                       'yarn_app_mapreduce_am_resource_mb': '512'}
        },
        {
            "type": "NODEMANAGER",
            "config":
                {
                    'yarn_nodemanager_heartbeat_interval_ms': 100,
                    'yarn_nodemanager_local_dirs': '/data0/yarn/nm',
                    'yarn_nodemanager_log_dirs': '/var/log/pnda/hadoop-yarn/container',
                    'yarn_nodemanager_resource_cpu_vcores': '8',
                    'yarn_nodemanager_resource_memory_mb': '4096',
                    'yarn_nodemanager_localizer_cache_target_size_mb': '1024',
                    'yarn_nodemanager_log_retain_seconds': '7200',
                    'node_manager_log_dir': '/var/log/pnda/hadoop-yarn',
                    'nodemanager_local_data_directories_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                    'nodemanager_log_directories_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                    'nodemanager_recovery_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                    'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                    'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                    'max_log_backup_index': '2',
                    'max_log_size': '100'
                }
        },
        {
            "type": "JOBHISTORY",
            "config":
                {
                    'mr2_jobhistory_log_dir': '/var/log/pnda/hadoop-mapreduce',
                    'mapreduce_jobhistory_max_age_ms': '86400000',
                    'mr2_jobhistory_java_heapsize': '1073741824',
                    'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                    'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                    'max_log_backup_index': '2',
                    'max_log_size': '100'
                }
        },
        {
            "type": "RESOURCEMANAGER",
            "config":
                {
                    'resourcemanager_config_safety_valve':
                        '<property> \r\n<name>yarn.resourcemanager.proxy-user-privileges.enabled</name>\r\n<value>true</value>\r\n</property>',
                    'resource_manager_java_heapsize': '1073741824',
                    'resource_manager_log_dir': '/var/log/pnda/hadoop-yarn',
                    'resourcemanager_fair_scheduler_configuration': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?> <allocations> <queue name="root"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> </aclSubmitApps> <aclAdministerApps>pnda </aclAdministerApps><queue name="default"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps>pnda </aclSubmitApps> </queue> <queue name="applications" type="parent"> <weight>0.0</weight> <schedulingPolicy>fair</schedulingPolicy> <queue name="dev"> <weight>0.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> dev,prod</aclSubmitApps> </queue> <queue name="prod"> <weight>1.0</weight> <schedulingPolicy>fair</schedulingPolicy> <aclSubmitApps> prod</aclSubmitApps> </queue> </queue> </queue> <defaultQueueSchedulingPolicy>fair</defaultQueueSchedulingPolicy> <queuePlacementPolicy> <rule name="specified" create="false"/> <rule name="default"/> </queuePlacementPolicy> </allocations>',
                    'log_directory_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                    'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                    'max_log_backup_index': '2',
                    'max_log_size': '100',
                    'yarn_scheduler_increment_allocation_mb': '256',
                    'yarn_scheduler_maximum_allocation_mb': '4096',
                    'yarn_scheduler_maximum_allocation_vcores': '1',
                    'yarn_scheduler_minimum_allocation_vcores': '1',
                    'yarn_scheduler_minimum_allocation_mb': '256'
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
            'dfs_replication': 1,
            'core_site_safety_valve':
                ('<property> <name>hadoop.tmp.dir</name><value>/data0/tmp/hadoop-${user.name}</value></property>\r\n\r\n'
                 '<property> \r\n<name>hadoop.proxyuser.yarn.hosts</name>\r\n<value>*</value>\r\n</property>\r\n\r\n'
                 '<property>\r\n<name>hadoop.proxyuser.yarn.groups</name>\r\n<value>*</value>\r\n</property>') + SWIFT_CONFIG + S3_CONFIG,
            'dfs_block_local_path_access_user': 'impala',
            'hdfs_missing_blocks_thresholds': '{"warning":"never","critical":100}'
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
                "target": "MGR01"
            },
            {
                "name": "hdfs-dn",
                "type": "DATANODE",
                "target": "DATANODE"
            },
            {
                "name": "hdfs-httpfs",
                "type": "HTTPFS",
                "target": "MGR01"
            },
            {
                "name": "hdfs-gw",
                "type": "GATEWAY",
                "target": "EDGE"
            }
        ],
    "role_cfg":
        [
            {
                "type": "NAMENODE",
                "config": {'dfs_name_dir_list': '/data0/nn',
                           'dfs_namenode_handler_count': 60,
                           'dfs_namenode_service_handler_count': 60,
                           'dfs_namenode_servicerpc_address': '8022',
                           'namenode_log_dir': '/var/log/pnda/hadoop/nn',
                           'namenode_java_heapsize': 1073741824,
                           'dfs_qjournal_write_txns_timeout_ms': 120000,
                           'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                           'max_log_backup_index': '2',
                           'max_log_size': '100',
                           'namenode_data_directories_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}'}
            },
            {
                "type": "DATANODE",
                "config": {'dfs_data_dir_list': '{{ data_volumes }}', 'datanode_log_dir': '/var/log/pnda/hadoop/dn',
                           'datanode_data_directories_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                           'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'max_log_backup_index': '2',
                           'max_log_size': '100',
                           'dfs_datanode_max_locked_memory':'1073741824'
                           }
            },
            {
                "type": "SECONDARYNAMENODE",
                "config": {'fs_checkpoint_dir_list': '/data0/snn',
                           'secondarynamenode_log_dir': '/var/log/pnda/hadoop/snn',
                           'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                           'max_log_backup_index': '2',
                           'max_log_size': '100',
                           'secondary_namenode_java_heapsize': '1073741824',
                           'secondarynamenode_checkpoint_directories_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}'}
            },
            {
                "type": "HTTPFS",
                "config": {'httpfs_log_dir': '/var/log/pnda/hadoop-httpfs',
                           'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
						   'max_log_backup_index': '2',
						   'max_log_size': '100'}
            }

        ]
}

HBASE_CFG = {
    "service": "HBASE",
    "name": "hbase01",
    "config": {'hdfs_service': 'hdfs01', 'zookeeper_service': 'zk01', 'rm_dirty': 'true'},
    "roles":
        [
            {
                "name": "master",
                "type": "MASTER",
                "target": "MGR01"
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
                "name": "hbase-restserver",
                "type": "HBASERESTSERVER",
                "target": "MGR01"
            },
            {
                "name": "hbase-thriftserver",
                "type": "HBASETHRIFTSERVER",
                "target": "MGR01"
            }
        ],
    "role_cfg": [
        {
            "type": "HBASERESTSERVER",
            "config": {'hbase_restserver_log_dir': '/var/log/pnda/hbase',
                       'hbase_restserver_java_heapsize': '402653184',
                       'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                       'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                       'max_log_backup_index': '2',
                       'max_log_size': '100'}
        },
        {
            "type": "HBASETHRIFTSERVER",
            "config": {'hbase_thriftserver_log_dir': '/var/log/pnda/hbase',
                       'hbase_thriftserver_java_heapsize': '671088640',
                       'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                       'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                       'max_log_backup_index': '2',
                       'max_log_size': '100'}
        },
        {
            "type": "MASTER",
            "config": {'hbase_master_log_dir': '/var/log/pnda/hbase', 'hbase_master_java_heapsize': '402653184',
                       'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                       'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                       'max_log_backup_index': '2',
                       'max_log_size': '100'}
        },
        {
            "type": "REGIONSERVER",
            "config": {'hbase_regionserver_log_dir': '/var/log/pnda/hbase',
                       'hbase_regionserver_java_heapsize': '805306368',
                       'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                       'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                       'max_log_backup_index': '2',
                       'max_log_size': '100'}
        },
        {
            "type": "GATEWAY",
            "config": {'hbase_client_java_heapsize': '104857600'}
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
                "target": "MGR01"
            },
            {
                "name": "hive-server",
                "type": "HIVESERVER2",
                "target": "MGR01"
            }
        ],
    "role_cfg":
        [
            {
                "type": "HIVEMETASTORE",
                "config": {'hive_log_dir': '/var/log/pnda/hive',
                           'hive_metastore_java_heapsize': '1073741824',
                           'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                           'max_log_backup_index': '2',
                           'max_log_size': '100'}
            },
            {
                "type": "HIVESERVER2",
                "config": {'hive_log_dir': '/var/log/pnda/hive', 'hiveserver2_java_heapsize': '1073741824',
                           'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                           'max_log_backup_index': '2',
                           'max_log_size': '100'}
            },
            {
                "type": "GATEWAY",
                "config": {}
            },
            {
                "type": "WEBHCAT",
                "config": {'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                           'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                           'max_log_backup_index': '2',
                           'max_log_size': '100'}
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
        {'name': 'impala-CATALOGSERVER', 'type': 'CATALOGSERVER', 'target': 'MGR01'},
        {'name': 'impala-IMPALAD', 'type': 'IMPALAD', 'target': 'DATANODE'},
        {'name': 'impala-STATESTORE', 'type': 'STATESTORE', 'target': 'MGR01'}
    ],
    'role_cfg': [
        {'type': 'IMPALAD', 'config': {'impalad_memory_limit': '1073741824',
                                       'scratch_dirs': '/impala/impalad',
                                       'log_dir': '/var/log/pnda/impala',
                                       'impalad_scratch_directories_free_space_absolute_thresholds': '{"warning":1073741824,"critical":1073741824}',
                                       'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                                       'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                                       'max_log_size': '100'}},
        {'type': 'CATALOGSERVER', 'config': {'log_dir': '/var/log/pnda/impala',
                                             'catalogd_embedded_jvm_heapsize': "1073741824",
                                             'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                                             'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                                             'max_log_size': '100'}},
        {'type': 'STATESTORE', 'config': {'log_dir': '/var/log/pnda/impala',
									      'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                                          'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
									      'max_log_size': '100'}},
        {'type': 'LLAMA', 'config': {'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}',
                                     'heap_dump_directory_free_space_absolute_thresholds': '{"warning":"never","critical":5368709120}',
                                     'llama_log_dir': '/var/log/pnda/impala-llama',
									 'max_log_backup_index': '2',
									 'max_log_size': '100'}}
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
                "target": "MGR01"
            }
        ],
    "role_cfg":
        [
            {
                "type": "HUE_SERVER",
                "config": {'hue_server_log_dir': '/var/log/pnda/hue', 'secret_key': 'Abcd1234',
						   'log_directory_free_space_absolute_thresholds': '{"warning":4294967296,"critical":3221225472}'}
            }
        ]
}

SPARK_CFG = {
    'service': 'SPARK_ON_YARN',
    'name': 'spark_on_yarn',
    'config': {
        'yarn_service': MAPRED_CFG['name'],
        'spark-conf/spark-env.sh_service_safety_valve': "SPARK_PYTHON_PATH={{ app_packages_dir }}/lib/python2.7/site-packages\nexport PYTHONPATH=\"$PYTHONPATH:$SPARK_PYTHON_PATH\""
    },
    'roles': [
        {'name': 'spark', 'type': 'SPARK_YARN_HISTORY_SERVER', 'target': 'MGR01'},
        {'name': 'spark_gw1', 'type': 'GATEWAY', 'target': 'EDGE'},
        {'name': 'spark_gw2', 'type': 'GATEWAY', 'target': 'DATANODE'}
    ],
    'role_cfg': [
        {'type': 'SPARK_YARN_HISTORY_SERVER', 'config': {}},
        {'type': 'GATEWAY', 'config': {
            'spark_history_enabled': 'false',
            'spark-conf/spark-defaults.conf_client_config_safety_valve': 'spark.yarn.executor.memoryOverhead=256\nspark.driver.memory=384m\nspark.executor.memory=384m\nspark.yarn.am.memory=384m\nspark.executor.cores=1\nspark.metrics.conf.*.sink.graphite.class=org.apache.spark.metrics.sink.GraphiteSink\nspark.metrics.conf.*.sink.graphite.host={{ pnda_graphite_host }}\nspark.metrics.conf.*.sink.graphite.port=2003\nspark.metrics.conf.*.sink.graphite.period=60\nspark.metrics.conf.*.sink.graphite.prefix=spark\nspark.metrics.conf.*.sink.graphite.unit=seconds\nspark.metrics.conf.master.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.metrics.conf.worker.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.metrics.conf.driver.source.jvm.class=org.apache.spark.metrics.source.JvmSource\nspark.metrics.conf.executor.source.jvm.class=org.apache.spark.metrics.source.JvmSource',
            'spark_dynamic_allocation_max_executors': '4'}}
    ]
}
