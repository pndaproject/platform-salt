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
            "listen_iface": "vlan2506"
        },
        "kafka.server": {
            "kafka_log_retention_bytes": 1073741824
        }
    }
}
}
