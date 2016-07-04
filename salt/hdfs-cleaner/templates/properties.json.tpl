{%- set cm_node = [] %}
{%- set pnda_cluster = salt['pnda.cluster_name']() %}
{%- for server, addrs in salt['mine.get']("G@pnda_cluster:"+pnda_cluster+" and G@roles:cloudera_manager", 'network.ip_addrs', expr_form='compound').items() %}
{%- do cm_node.append(addrs[0]) %}
{%- endfor %}
{%- set cm_node_ip = cm_node|join(" ") %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}
{
    "cm_host":"{{ cm_node_ip }}",
    "cm_user":"{{ cm_username }}",
    "cm_pass":"{{ cm_password }}",
    "datasets_table":"platform_datasets",
    "spark_streaming_dirs_to_clean": [
        "/user/hdfs/.sparkStaging/",
        "/tmp/logs/hdfs/logs/",
        "/user/spark/applicationHistory/"
    ],
    "general_dirs_to_clean":["/user/history/done/"],
    "old_dirs_to_clean": [
        {"name": "/user/gobblin/work/metrics", "age_seconds": 172800}
    ],
    "swift_repo": "{{ archive_type }}://{{ container }}{{ archive_service }}/{{ repo_path }}"
}
