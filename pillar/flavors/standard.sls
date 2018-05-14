#!json

{
"pnda_flavor": {
    "name": "standard",
    "description": "This it the standard, default PNDA flavor",

    "states": {
        "gobblin": {
            "max_mappers": 50
        },
        "kafka.server": {
            "data_dirs": ["/var/kafka-logs"],
            "kafka_log_retention_bytes": 1073741824,
            "kafka_heapsize": 4294967296
        },
        "cdh.setup_hadoop": {
            "template_file": "cfg_standard.py"
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_standard.py"
        },
        "curator": {
            "days_to_keep": 6
        },
        "zookeeper": {
            "zookeeper_heapsize": 2147483648,
            "zookeeper_data_dir": "/var/lib/zookeeper"
        },
        "opentsdb": {
            "opentsdb_heapsize": 4294967296
        },
        "mysql": {
            "data_dir": "/var/lib/mysql"
        },
        "elasticsearch": {
            "datadir": "/var/lib/elasticsearch"
        },
        "flink": {
            "jobmanager_heapsize": 2048,
            "taskmanager_heapsize": 2048,
            "taskmanager_slots": 1,
            "parallelism": 1,
            "taskmanager_mem_preallocate": false,
            "pyflink_yarn_container_count": 1
        },
        "graphite-api":{
            "retention_spark_metrics": "60:10080"
        }
    }
}
}
