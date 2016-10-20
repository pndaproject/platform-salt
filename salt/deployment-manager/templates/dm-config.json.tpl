{%- set keystone_user = salt['pillar.get']('keystone.user', '') -%}
{%- set keystone_password = salt['pillar.get']('keystone.password', '') -%}
{%- set keystone_account = salt['pillar.get']('keystone.tenant', '') -%}
{%- set keystone_url = salt['pillar.get']('keystone.auth_url', '') -%}
{%- set os_user = salt['pillar.get']('os_user', 'cloud-user') -%}
{%- set pnda_cluster = salt['pnda.cluster_name']() -%}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_ips']() -%}
{%- do kafka_brokers.append(ip+':9092') -%}
{%- endfor -%}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}


{% set opentsdb_link = salt['pnda.generate_http_link']('opentsdb',':4242') %}
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

{%- set cm_node_ip = salt['pnda.cloudera_manager_ip']() -%}
{%- set cm_username = pillar['admin_login']['user'] -%}
{%- set cm_password = pillar['admin_login']['password'] -%}
{%- set pnda_cluster = salt['pnda.cluster_name']() -%}

{% set repository_manager_link = salt['pnda.generate_http_link']('package_repository',':8888') %}

{
    "environment": {
        "queue_name":"default",
        "cloudera_manager_host" : "{{ cm_node_ip }}",
        "cloudera_manager_username" : "{{ cm_username }}",
        "cloudera_manager_password" : "{{ cm_password }}",
        "cluster_root_user" : "{{ os_user }}",
        "cluster_private_key" : "./dm.pem",
        "kafka_zookeeper" : "{{ kafka_zookeepers|join(',') }}",
        "kafka_brokers" : "{{ kafka_brokers|join(',') }}",
        "opentsdb" : "{{ opentsdb_link }}",
        "kafka_manager" : "{{ km_link }}",
        "namespace": "platform_app",
        "metric_logger_url": "{{ data_logger_link }}/metrics",
        "jupyter_host": "{{ jupyter_host }}",
        "jupyter_notebook_directory": "{{ pnda_home_directory }}/jupyter_notebooks"
    },
    "HDFSRegistrar": {
        "records_path": "user/deployment/record.json",
        "webhdfs_user": "hdfs"
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
