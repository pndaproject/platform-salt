{%- set cm_node_ip = salt['pnda.hadoop_manager_ip']() -%}
{%- set cm_username = pillar['admin_login']['user'] -%}
{%- set cm_password = pillar['admin_login']['password'] -%}
{%- set hadoop_distro = pillar['hadoop.distro'] -%}
{
    "hadoop_distro":"{{ hadoop_distro }}",
    "cm_host":"{{ cm_node_ip }}",
    "cm_user":"{{ cm_username }}",
    "cm_pass":"{{ cm_password }}",
    "log_level": "INFO"
}
