{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set flink_version = pillar['flink']['release_version'] %}

{% if grains['hadoop.distro'] == 'HDP' %}
{% set flink_package = 'flink-' + flink_version + '-HDP.tar.gz' %}
{% else %}
{% set flink_package = 'flink-' + flink_version + '-CDH.tar.gz' %}
{% endif %}

{% set pnda_home = pillar['pnda']['homedir'] %}
{% set pnda_user  = pillar['pnda']['user'] %}
{% set flink_real_dir = pnda_home + '/flink-' + flink_version %}
{% set flink_link_dir = pnda_home + '/flink' %}

{% set namenode = salt['pnda.hadoop_namenode']() %}
{% set archive_dir = pnda_user + '/flink/completed-jobs' %}
{% set archive_dir_hdfs_path = namenode + '/' + archive_dir %}

{% set historyserver_web_port = salt['grains.get']('flink:history_server_port',8082) %}
{% set jobmanager_web_port = salt['grains.get']('flink:jobmanager_web_port',8083) %}

{% if grains['hadoop.distro'] == 'HDP' %}
{% set hadoop_home_bin = '/usr/hdp/current/hadoop-client/bin/' %}
{% else %}
{% set hadoop_home_bin = '/opt/cloudera/parcels/CDH/bin' %}
{% endif %}

flink-create_flink_version_directory:
  file.directory:
    - name: {{ flink_real_dir }}
    - makedirs: True

flink-dl-and-extract:
  archive.extracted:
    - name: {{ flink_real_dir }}
    - source: {{ packages_server }}/{{ flink_package }}
    - source_hash: {{ packages_server }}/{{ flink_package }}.sha512.txt
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ flink_real_dir }}/bin
    - require:
      - file: flink-create_flink_version_directory

flink-copy_configurations:
  file.managed:
    - name: {{ flink_real_dir }}/conf/flink-conf.yaml
    - source: salt://flink/templates/flink.conf.tpl
    - template: jinja
    - context:
      jmnode: 'localhost'
      namenode: {{ namenode }}
      path: {{ archive_dir }}
      historyserver_web_port: {{ historyserver_web_port }}
      jobmanager_web_port: {{ jobmanager_web_port }}
      jobmanager_heap_mb: {{ flavor_cfg.jobmanager_heapsize }}
      taskmanager_heap_mb: {{ flavor_cfg.taskmanager_heapsize }}
      taskmanager_slots: {{ flavor_cfg.taskmanager_slots }}
      parallelism: {{ flavor_cfg.parallelism }}
      taskmanager_mem_preallocate: {{ flavor_cfg.taskmanager_mem_preallocate }}

flink-configure_log_dir:
  file.directory:
    - name: {{ flink_real_dir }}/log
    - makedirs: True
    - user: pnda
    - group: pnda
    - mode: 0744

flink-create_link:
  file.symlink:
    - name: {{ flink_link_dir }}
    - target: {{ flink_real_dir }}
    - require:
      - archive: flink-dl-and-extract

flink-create_flink_logs_directory:
  file.directory:
    - name: /var/log/pnda/flink
    - user: {{ pnda_user }}
    - makedirs: True

flink-jobmanager_archive_dir_initialize-hdfs:
  cmd.run:
    - name: 'sudo -u hdfs hdfs dfs -mkdir -p {{ archive_dir_hdfs_path }}; sudo -u hdfs hdfs dfs -chmod 777 {{ archive_dir_hdfs_path }}'

flink-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/flink-history-server.conf
    - source: salt://flink/templates/flink-service.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /usr/lib/systemd/system/flink-history-server.service
    - source: salt://flink/templates/flink-service.service.tpl
{% endif %}
    - template: jinja
    - defaults:
        install_dir: {{ flink_link_dir }}

flink-history_server_start_service:
  service.running:
    - name: flink-history-server
    - enable: True
    - reload: True
