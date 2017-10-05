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
            "kafka_log_retention_bytes": 1073741824
        }
    }
}
}
