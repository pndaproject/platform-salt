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
            "template_file": "cfg_production.py",
            "data_volumes_count": 24
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_production.py",
            "data_volumes_count": 24
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
        }
    }
}
}
