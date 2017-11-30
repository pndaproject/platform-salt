{%- set os_user = salt['pillar.get']('os_user', 'cloud-user') -%}
{%- set pnda_cluster = salt['pnda.cluster_name']() -%}
{%- set hadoop_distro = pillar['hadoop.distro'] -%}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_ips']() -%}
{%- do kafka_brokers.append(ip+':9092') -%}
{%- endfor -%}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}

{%- set opentsdb_port = salt['pillar.get']('opentsdb:bind_port', 4242) -%}
{%- set opentsdb_nodes = salt['pnda.ip_addresses']('opentsdb') -%}
{%- set opentsdb_host = '' -%}
{%- if opentsdb_nodes is not none and opentsdb_nodes|length > 0 -%}
    {%- set opentsdb_host = opentsdb_nodes[0]+':'+opentsdb_port|string -%}
{%- else -%}
    {%- set opentsdb_host = '' -%}
{%- endif -%}

{% set km_link = salt['pnda.generate_http_link']('kafka_manager',':'+km_port|string+'/clusters/'+pnda_cluster) %}

{%- set jupyter_nodes = salt['pnda.ip_addresses']('jupyter') -%}
{%- set jupyter_host = '' -%}
{%- if jupyter_nodes is not none and jupyter_nodes|length > 0 -%}
    {%- set jupyter_host = jupyter_nodes[0] -%}
{%- else -%}
    {%- set jupyter_host = '' -%}
{%- endif -%}

{%- set pnda_home_directory = pillar['pnda']['homedir'] -%}

{%- set data_logger_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') -%}
{%- set data_logger_link = salt['pnda.generate_http_link']('console_backend_data_logger',':'+data_logger_port|string) -%}

{%- set cm_node_ip = salt['pnda.hadoop_manager_ip']() -%}
{%- set cm_username = pillar['admin_login']['user'] -%}
{%- set cm_password = pillar['admin_login']['password'] -%}

{% if pillar['identity']['pam_module'] == 'pam_unix' %}
{%- set application_default_user = pillar['identity']['users'][1]['user'] -%}
{%- else -%}
{%- set application_default_user = '' -%}
{% endif %}

{% set repository_manager_link = salt['pnda.generate_http_link']('package_repository',':8888') %}

{%- set keys_directory = pillar['deployment_manager']['keys_directory'] -%}


{
    "environment": {
        "hadoop_distro":"{{ hadoop_distro }}",
        "queue_name":"default",
        "hadoop_manager_host" : "{{ cm_node_ip }}",
        "hadoop_manager_username" : "{{ cm_username }}",
        "hadoop_manager_password" : "{{ cm_password }}",
        "cluster_root_user" : "{{ os_user }}",
        "cluster_private_key" : "{{ keys_directory }}/dm.pem",
        "kafka_zookeeper" : "{{ kafka_zookeepers|join(',') }}",
        "kafka_brokers" : "{{ kafka_brokers|join(',') }}",
        "opentsdb" : "{{ opentsdb_host }}",
        "kafka_manager" : "{{ km_link }}",
        "namespace": "platform_app",
        "metric_logger_url": "{{ data_logger_link }}/metrics",
        "jupyter_host": "{{ jupyter_host }}",
        "jupyter_notebook_directory": "jupyter_notebooks",
        "application_default_user": "{{ application_default_user }}"
    },
    "config": {
        "stage_root": "stage",
        "plugins_path": "plugins",
        "log_level": "INFO",
        "deployer_thread_limit": 100,
        "package_callback": "{{ data_logger_link }}/packages",
        "application_callback": "{{ data_logger_link }}/applications",
        "package_repository": "{{ repository_manager_link }}"
    }
}
