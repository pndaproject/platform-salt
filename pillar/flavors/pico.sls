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
            "zookeeper_heapsize": 1073741824
        },
        "opentsdb": {
            "opentsdb_heapsize": 2147483648
        }
    }
}
}
