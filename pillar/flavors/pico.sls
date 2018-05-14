#!json

{
"pnda_flavor": {
    "name": "pico",
    "description": "This it the pico PNDA flavor, used for really tiny clusters",

    "states": {
        "gobblin": {
            "max_mappers": 5
        },
        "kafka.server": {
            "data_dirs": ["/var/kafka-logs"],
            "kafka_log_retention_bytes": 314572800,
            "kafka_heapsize": 2147483648
        },
        "cdh.setup_hadoop": {
            "template_file": "cfg_pico.py"
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_pico.py"
        },
        "curator": {
            "days_to_keep": 1
        },
        "zookeeper": {
            "zookeeper_heapsize": 1073741824,
            "zookeeper_data_dir": "/var/lib/zookeeper"
        },
        "opentsdb": {
            "opentsdb_heapsize": 2147483648
        },
        "mysql": {
            "data_dir": "/var/lib/mysql"
        },
        "elasticsearch": {
            "datadir": "/var/lib/elasticsearch"
        },
        "flink": {
            "jobmanager_heapsize": 1024,
            "taskmanager_heapsize": 1024,
            "taskmanager_slots": 1,
            "parallelism": 1,
            "taskmanager_mem_preallocate": false,
            "pyflink_yarn_container_count": 1
        },
        "graphite-api":{
            "retention_spark_metrics": "60:1440"
        }
    }
}
}
