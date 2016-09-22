#!json

{
"pnda_flavor": {
    "name": "pico",
    "description": "This it the pico PNDA flavor, used for really tiny clusters",

    "states": {
        "gobblin": {
            "max_mappers": 5
        },
        "cdh.setup_hadoop": {
            "template_file": "cfg_pico.py"
        }
    }
}
}
