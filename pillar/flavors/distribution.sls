#!json

{
"pnda_flavor": {
    "name": "distribution",
    "description": "This it the distribution flavor, without the hadoop part",

    "states": {
        "curator": {
            "days_to_keep": 6
        },
        "kafka.settings": {
            "listen_iface": "vlan2506"
        },
        "zookeeper": {
            "listen_iface": "vlan2506",
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
