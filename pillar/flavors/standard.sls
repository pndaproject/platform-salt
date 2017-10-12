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
            "zookeeper_heapsize": 2147483648
        },
        "opentsdb": {
            "opentsdb_heapsize": 4294967296
        }
    }
}
}
