#!json

{
"pnda_flavor": {
    "name": "bmstandard",
    "description": "This it the bmstandard, default PNDA flavor",

    "states": {
        "gobblin": {
            "max_mappers": 50
        },
        "cdh.setup_hadoop": {
            "template_file": "cfg_bmstandard.py"
        },
        "hdp.setup_hadoop": {
            "template_file": "cfg_bmstandard.py"
        },
        "curator": {
            "days_to_keep": 6
        },
        "kafka.settings": {
            "listen_iface": "vlan2006"
        },
        "zookeeper": {
            "listen_iface": "vlan2006",
            "zookeeper_data_dir": "/var/lib/zookeeper"
        },
        "kafka.server": {
            "data_dirs": ["/var/kafka-logs"],
            "kafka_log_retention_bytes": 1073741824
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
