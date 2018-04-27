{%- set os_user = pillar['os_user'] -%}
{%- set pnda_cluster = salt['pnda.cluster_name']() -%}
{%- set hadoop_distro = grains['hadoop.distro'] -%}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_hosts']() -%}
{%- do kafka_brokers.append(ip+':9092') -%}
{%- endfor -%}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_hosts']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}

{%- set opentsdb_port = pillar['opentsdb']['bind_port'] -%}
{%- set opentsdb_nodes = salt['pnda.get_hosts_for_role']('opentsdb') -%}
{%- set opentsdb_host = '' -%}
{%- if opentsdb_nodes is not none and opentsdb_nodes|length > 0 -%}
    {%- set opentsdb_host = opentsdb_nodes[0]+':'+opentsdb_port|string -%}
{%- else -%}
    {%- set opentsdb_host = '' -%}
{%- endif -%}

{% set km_link = salt['pnda.generate_http_link']('kafka_manager',':'+km_port|string+'/clusters/'+pnda_cluster) %}

{%- set jupyter_nodes = salt['pnda.get_hosts_for_role']('jupyter') -%}
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

{% set repository_manager_link = salt['pnda.generate_http_link']('package_repository',':8888') %}

{%- set keys_directory = pillar['deployment_manager']['keys_directory'] -%}
{% set app_packages_hdfs_path = pillar['pnda']['app_packages']['app_packages_hdfs_path'] -%}

{% set policy_file_link = pillar['resource_manager']['path'] + pillar['resource_manager']['policy_file'] %}
{%- set flink_lib_dir = pillar['pnda']['homedir'] + '/flink/lib' -%}
{%- set flink_history_server_port = salt['pillar.get']('flink:history_server_port', 8082) -%}
{%- set fh_nodes = salt['pnda.get_hosts_for_role']('flink') -%}
{%- set flink_host = fh_nodes[0] -%}
{%- set flink_history_server = flink_host+':'+flink_history_server_port|string -%}

{% set resource_manager_path = pillar['resource_manager']['path'] %}

{% set oozie_spark_version = pillar['hdp']['oozie_spark_version'] %}

{
    "environment": {
        "hadoop_distro":"{{ hadoop_distro }}",
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
        "app_packages_hdfs_path":"{{ app_packages_hdfs_path }}",
        "queue_policy": "{{ policy_file_link }}",
        "flink_lib_dir": "{{ flink_lib_dir }}",
        "flink_history_server": "{{ flink_history_server }}",
        "spark_submit": "{{ resource_manager_path }}/bin/spark-submit",
        "flink_host" : "{{ flink_host }}",
        "flink": "{{ resource_manager_path }}/bin/flink"
    },
    "config": {
        "stage_root": "stage",
        "plugins_path": "plugins",
        "log_level": "INFO",
        "deployer_thread_limit": 100,
        "environment_sync_interval": 120,
        "package_callback": "{{ data_logger_link }}/packages",
        "application_callback": "{{ data_logger_link }}/applications",
        "package_repository": "{{ repository_manager_link }}",
        "oozie_spark_version": "{{ oozie_spark_version }}"
    }
}
