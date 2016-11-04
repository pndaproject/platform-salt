{%- set cm_node_ip = salt['pnda.cloudera_manager_ip']() -%}
{%- set cm_username = pillar['admin_login']['user'] -%}
{%- set cm_password = pillar['admin_login']['password'] -%}
{
    "cm_host":"{{ cm_node_ip }}",
    "cm_user":"{{ cm_username }}",
    "cm_pass":"{{ cm_password }}",
    "log_level": "INFO"
}
