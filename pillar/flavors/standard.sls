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
            "template_file": "cfg_standard.py",
            "data_volumes_count": 1
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_standard.py",
            "data_volumes_count": 1
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
        }
    }
}
}
