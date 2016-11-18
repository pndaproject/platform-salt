#!json

{
"pnda_flavor": {
    "name": "standard",
    "description": "This it the standard, default PNDA flavor",

    "states": {
        "gobblin": {
            "max_mappers": 50
        },
        "cdh.setup_hadoop": {
            "template_file": "cfg_standard.py"
        },
        "curator": {
            "days_to_keep": 6
        }
    }
}
}
