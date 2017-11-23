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
            "template_file": "cfg_pico.py",
            "data_volumes_count": 1
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_pico.py",
            "data_volumes_count": 1
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
        }
    }
}
}
