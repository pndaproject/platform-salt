{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set console_frontend_version = pillar['console_frontend']['release_version'] %}
{% set console_frontend_package = 'console-frontend-' + console_frontend_version + '.tar.gz' %}
{% set nginx_config_location = '/etc/nginx/conf.d' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set console_dir = install_dir + '/console-frontend' %}
{% set console_config_dir = console_dir + '/conf' %}
{% set console_demo_dir = console_dir + '/js/demo' %}
{% set nginx_port = salt['pillar.get']('console_frontend:bind_port', '80') %}
{% set clustername = salt['pnda.cluster_name']() %}
{% set frontend_version = salt['pillar.get']('console_frontend:release_version', 'unknown') %}
{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}
{% set hadoop_distro = grains['hadoop.distro'] %}
{% set data_manager_host = salt['pnda.get_hosts_for_role']('console_backend_data_manager')[0] %}
{% set data_manager_port = salt['pillar.get']('console_backend_data_manager:bind_port', '3123') %}
{% set data_manager_version = salt['pillar.get']('console_backend_data_manager:release_version', 'unknown') %}
{% if salt['grains.get']('hadoop.distro') == 'HDP' %}
  {% set hive_version = salt['pillar.get']('hadoop_components_version:hive') %}
  {% set hbase_version = salt['pillar.get']('hadoop_components_version:hbase') %}
  {% set hdfs_version =  salt['pillar.get']('hadoop_components_version:hdfs') %}
  {% set spark_version = salt['pillar.get']('hadoop_components_version:spark') %}
  {% set spark2_version = salt['pillar.get']('hadoop_components_version:spark2') %}
  {% set oozie_version =  salt['pillar.get']('hadoop_components_version:oozie') %}
  {% set yarn_version = salt['pillar.get']('hadoop_components_version:yarn') %}
  {% set flink_version = salt['pillar.get']('flink:release_version') %}
  {% set kafka_version = salt['pillar.get']('kafka:version') %}
  {% set zookeeper_version = salt['pillar.get']('zookeeper:version') %}
  {% set opentsdb_version = salt['pillar.get']('opentsdb:version') %}
{% else %}
  {% set hive_version, hbase_version, hdfs_version, spark_version, spark2_version,
  oozie_version, flink_version, yarn_version, zookeeper_version, kafka_version, opentsdb_version = '', '', '', '', '', '', '', '', '', '', '' %}
{% endif %}

# edge node IP
{% set edge_nodes = salt['pnda.get_hosts_for_role']('hadoop_edge') %}
{%- if edge_nodes is not none and edge_nodes|length > 0 -%}
    {%- set edge_node_ip = edge_nodes[0] -%}
{%- else -%}
    {%- set edge_node_ip = '' -%}
{%- endif -%}

{%- if grains['hadoop.distro'] == 'CDH' -%}
{% set cm_port = ':7180' %}
{%- else -%}
{% set cm_port = ':8080' %}
{%- endif -%}

# Set links through gateway roles
{% set yarn_link = salt['pnda.get_gateway_link']('yarn') %}
{% set hadoop_manager_link = salt['pnda.get_gateway_link']('ambari') %}
{% set jupyter_link = salt['pnda.get_gateway_link']('jupyter') %}
{% set grafana_link = salt['pnda.get_gateway_link']('grafana') %}
{% set httpfs_link = salt['pnda.get_gateway_link']('httpfs') %}
{% set km_link = salt['pnda.get_gateway_link']('kafka-manager') + '/clusters/' + clustername %}
{% set kibana_link = salt['pnda.get_gateway_link']('kibana') %}
{% set flink_link = salt['pnda.get_gateway_link']('flink') + '/' %}

{% set login_mode = 'PAM' %}

include:
  - nodejs

console-frontend-dl-and-extract:
  archive.extracted:
    - name: {{ console_dir }}-{{ console_frontend_version }}
    - source: {{ packages_server }}/{{ console_frontend_package }}
    - source_hash: {{ packages_server }}/{{ console_frontend_package }}.sha512.txt
    - user: root
    - group: nginx
    - archive_format: tar
    - tar_options: --strip-components=1
    - if_missing: {{ console_dir }}-{{ console_frontend_version }}

console-frontend-create_directory_link:
  file.symlink:
    - name: {{ console_dir }}
    - target: {{ console_dir }}-{{ console_frontend_version }}

# Install npm dependencies
console-frontend-install_app_dependencies:
  cmd.run:
    - cwd: {{ console_dir }}
    - name: npm rebuild > /dev/null
    - require:
      - archive: nodejs-dl_and_extract_node

# Create the config directory if it doesn't exist
console-frontend-create_config_directory:
  file.directory:
    - names: [{{console_config_dir}}]
    - mode: 755
    - makedirs: True

# Create the log directory
console-create_logs_directory:
  file.directory:
    - name: /var/log/pnda/console
    - makedirs: True

# Create the PNDA console json file listing the services to access
console-frontend-create_pnda_console_config:
  file.managed:
    - source: salt://console-frontend/templates/PNDA.json.tpl
    - name: {{console_config_dir}}/PNDA.json
    - template: jinja
    - defaults:
        hadoop_distro: {{ hadoop_distro }}
        clustername: {{ clustername }}
        frontend_version: {{ frontend_version }}
        data_manager_version: {{ data_manager_version }}
        data_manager_host: {{ data_manager_host }}
        data_manager_port: {{ data_manager_port }}
        edge_node: {{ edge_node_ip }}
        hadoop_manager_link: "{{ hadoop_manager_link }}"
        kafka_manager_link: "{{ km_link }}"
        grafana_link: "{{ grafana_link }}"
        kibana_link: "{{ kibana_link }}"
        jupyter_link: "{{ jupyter_link }}"
        flink_link: "{{ flink_link }}"
        yarn_link: "{{ yarn_link }}"
        httpfs_link: "{{ httpfs_link }}"
        login_mode: "{{ login_mode }}"

console-frontend-create_pnda_console_topics:
  file.managed:
    - source: salt://console-frontend/templates/topics.json.tpl
    - name: {{console_dir}}/help/topics.json
    - template: jinja
    - makedirs: True
    - mode: 664
    - defaults:
        spark_version: "{{ spark_version }},{{ spark2_version }}"
        kafka_version: "{{ kafka_version }}"
        zookeeper_version: "{{ zookeeper_version }}"
        oozie_version: "{{ oozie_version }}"
        yarn_version: "{{ yarn_version }}"
        hdfs_version: "{{ hdfs_version }}"
        hive_version: "{{ hive_version }}"
        hbase_version: "{{ hbase_version }}"
        opentsdb_version: "{{ opentsdb_version }}"
        flink_version: "{{ flink_version }}"

# Create a configuration file for nginx and specify where the PNDA console file are
console-frontend-create_pnda_nginx_config:
  file.managed:
    - source: salt://console-frontend/templates/PNDA_nginx.conf.tpl
    - name: {{ nginx_config_location }}/PNDA.conf
    - template: jinja
    - defaults:
        console_dir: {{ console_dir }}
        port: {{ nginx_port }}
        data_manager_host: {{ data_manager_host }}
        data_manager_port: {{ data_manager_port }}

# Remove default nginx configuration
console-frontend-remove_nginx_default_config:
  file.absent:
    - name: {{nginx_config_location}}/default

console-frontend-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable nginx

console-frontend-start_service:
  cmd.run:
    - name: 'service nginx stop || echo already stopped; service nginx start'

