{%- set cm_node = [] %}
{%- set pnda_cluster = salt['pnda.cluster_name']() %}
{%- for server, addrs in salt['mine.get']("G@pnda_cluster:"+pnda_cluster+" and G@roles:hadoop_manager", 'network.ip_addrs', expr_form='compound').items() %}
{%- do cm_node.append(addrs[0]) %}
{%- endfor %}
{%- set cm_node_ip = cm_node|join(" ") %}
{%- set cm_username = pillar['admin_login']['user'] %}
{%- set cm_password = pillar['admin_login']['password'] %}
{%- set perform_compaction = salt['pillar.get']('dataset_compaction:compaction', False) %}

{%- if perform_compaction %}
{%- set compaction_pattern = salt['pillar.get']('dataset_compaction:pattern', 'd') %}
{%- if compaction_pattern == 'H' %}
{%- set age = 1 %}
{%- elif compaction_pattern == 'd' %}
{%- set age = 2 %}
{%- elif compaction_pattern == 'M' %}
{%- set age = 32 %}
{%- elif compaction_pattern == 'Y' %}
{%- set age = 367 %}
{%- endif %}
{%- set pnda_dataset_staging_location =  pillar['pnda']['master_dataset']['staging_directory'] %}
{%- set pnda_dataset_staging_retention_mode =  salt['pillar.get']('dataset_compaction:retention_mode', 'delete') %}
{%- endif %}
{
    "hadoop_distro":"{{ hadoop_distro }}",
    "cm_host":"{{ cm_node_ip }}",
    "cm_user":"{{ cm_username }}",
    "cm_pass":"{{ cm_password }}",
    "datasets_table":"platform_datasets",
    "spark_streaming_dirs_to_clean": [{{ streaming_dirs_to_clean }}],
    "general_dirs_to_clean": [{{ general_dirs_to_clean }}],
    "old_dirs_to_clean": [
        {"name": "{{ gobblin_work_dir }}/metrics", "age_seconds": 172800},
        {"name": "{{ gobblin_work_dir }}/state-store/PullFromKafkaMR", "age_seconds": 172800}
    ],
{%- if perform_compaction %}
    "staging_dataset_to_clean":{
        "staging_dataset_location": "{{ pnda_dataset_staging_location }}",
        "mode": "{{ pnda_dataset_staging_retention_mode }}",
        "age": {{ age }}
    },
{%- endif %}
    "swift_repo": "{{ archive_type }}://{{ container }}{{ archive_service }}/{{ repo_path }}",
    "container_name": "{{ container }}",
    "s3_archive_region": "{{ salt['pillar.get']('aws.archive_region', '') }}",
    "s3_archive_access_key": "{{ salt['pillar.get']('aws.archive_key', '') }}",
    "s3_archive_secret_access_key": "{{ salt['pillar.get']('aws.archive_secret', '') }}",
    "swift_account":"{{ salt['pillar.get']('keystone.tenant', '') }}",
    "swift_user": "{{ salt['pillar.get']('keystone.user', '') }}",
    "swift_key": "{{ salt['pillar.get']('keystone.password', '') }}",
    "swift_auth_url": "{{ salt['pillar.get']('keystone.auth_url', '') }}"
}
