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
            "kafka_log_retention_bytes": 1073741824
        },
        "mysql": {
            "data_dir": "/var/lib/mysql"
        },
        "elasticsearch": {
            "datadir": "/var/lib/elasticsearch"
        },
        "flink": {
            "jobmanager_heapsize": 2048,
            "taskmanager_heapsize": 2048,
            "taskmanager_slots": 1,
            "parallelism": 1,
            "taskmanager_mem_preallocate": false,
            "pyflink_yarn_container_count": 1
        }
    }
}
}
