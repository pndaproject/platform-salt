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
        }
    }
}
}
