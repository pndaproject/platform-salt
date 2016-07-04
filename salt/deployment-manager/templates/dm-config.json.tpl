{% set keystone_user = salt['pillar.get']('keystone.user', '') %}
{% set keystone_password = salt['pillar.get']('keystone.password', '') %}
{% set keystone_account = salt['pillar.get']('keystone.tenant', '') %}
{% set keystone_url = salt['pillar.get']('keystone.auth_url', '') %}

{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}

{% set pnda_cluster = salt['pnda.cluster_name']() %}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_ips']() -%}
{%- do kafka_brokers.append(ip+':9092') -%}
{%- endfor -%}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

{%- set opentsdb = [] -%}
{%- for ip in salt['pnda.ip_addresses']('opentsdb') -%}
{%- do opentsdb.append(ip+':4242') -%}
{%- endfor -%}

{%- set data_logger_ip = salt['pnda.ip_addresses']('console_backend')[0] -%}
{%- set data_logger_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') -%}

{%- set cm_node_ip = salt['pnda.cloudera_manager_ip']() -%}
{%- set cm_username = pillar['admin_login']['user'] -%}
{%- set cm_password = pillar['admin_login']['password'] -%}
{%- set km_ip = salt['pnda.ip_addresses']('tools')[0] -%}
{%- set pnda_cluster = salt['pnda.cluster_name']() -%}

{%- set repository_manager_ip = salt['pnda.ip_addresses']('package_repository')[0] -%}
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
        "opentsdb" : "{{ opentsdb|join(',') }}",
        "kafka_manager" : "http://{{ km_ip }}:9000/clusters/{{ pnda_cluster }}",
        "namespace": "platform_app",
        "metric_logger_url": "http://{{ data_logger_ip }}:{{ data_logger_port }}/metrics"
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
        "package_callback": "http://{{ data_logger_ip }}:{{ data_logger_port }}/packages",
        "application_callback": "http://{{ data_logger_ip }}:{{ data_logger_port }}/applications",
        "package_repository": "http://{{ repository_manager_ip }}:8888"
    }
}
