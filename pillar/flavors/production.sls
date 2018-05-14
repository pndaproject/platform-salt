#!json

{
"pnda_flavor": {
    "name": "production",
    "description": "This is the production flavor",

    "states": {
        "gobblin": {
            "max_mappers": 20
        },
        "cdh.setup_hadoop": {
            "template_file": "cfg_production.py"
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_production.py"
        },
        "curator": {
            "days_to_keep": 6
        },
        "kafka.server": {
            "data_dirs": ["/mnt/kafka-logs"],
            "kafka_log_retention_bytes": 1073741824,
            "kafka_heapsize": 17179869184
        },
        "zookeeper": {
            "zookeeper_heapsize": 4294967296,
            "zookeeper_data_dir": "/mnt/zookeeper"
        },
        "opentsdb": {
            "opentsdb_heapsize": 17179869184
        },
        "mysql": {
            "data_dir": "/mnt/mysql"
        },
        "elasticsearch": {
            "datadir": "/mnt/elasticsearch"
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
            "retention_spark_metrics": "60:20160"
        }
    }
}
}
