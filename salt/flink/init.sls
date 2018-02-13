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
{% set flink_hdfs_work_dir = '/user/' + pnda_user + '/flink/work' %}

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

flink-install_conf:
  file.managed:
    - name: {{ flink_real_dir }}/conf/flink-conf.yaml
    - source: salt://flink/templates/flink.conf.tpl
    - template: jinja
    - context:
      node: 'localhost'

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
