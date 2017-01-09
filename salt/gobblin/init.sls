{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set gobblin_version = pillar['gobblin']['release_version'] %}
{% set gobblin_package = 'gobblin-distribution-' + gobblin_version + '.tar.gz' %}

{% set pnda_home = pillar['pnda']['homedir'] %}
{% set pnda_user  = pillar['pnda']['user'] %}
{% set gobblin_real_dir = pnda_home + '/gobblin-' + gobblin_version %}
{% set gobblin_link_dir = pnda_home + '/gobblin' %}

{% set namenodes_ips = salt['pnda.namenodes_ips']() %}
# Only take the first one
{% set namenode = namenodes_ips[0] %}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_ips']() -%}
{%-   do kafka_brokers.append(ip + ':9092') -%}
{%- endfor -%}

{% set pnda_master_dataset_location = pillar['pnda']['master_dataset']['directory'] %}
{% set pnda_kite_dataset_uri = "dataset:hdfs://" + namenode + ":8020" + pnda_master_dataset_location %}

{% set pnda_quarantine_dataset_location = pillar['pnda']['master_dataset']['quarantine_directory'] %}
{% set pnda_quarantine_kite_dataset_uri = "dataset:hdfs://" + namenode + ":8020" + pnda_quarantine_dataset_location %}

{% set gobblin_hdfs_work_dir = '/user/' + pnda_user + '/gobblin/work' %}

gobblin-create_gobblin_version_directory:
  file.directory:
    - name: {{ gobblin_real_dir }}
    - makedirs: True

gobblin-dl-and-extract:
  archive.extracted:
    - name: {{ gobblin_real_dir }}
    - source: {{ packages_server }}/{{ gobblin_package }}
    - source_hash: {{ packages_server }}/{{ gobblin_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ gobblin_real_dir }}/gobblin-dist
    - require:
      - file: gobblin-create_gobblin_version_directory

gobblin-create_link:
  file.symlink:
    - name: {{ gobblin_link_dir }}
    - target: {{ gobblin_real_dir }}
    - require:
      - archive: gobblin-dl-and-extract

gobblin-update_gobblin_reference_configuration_file:
  file.replace:
    - name: {{ gobblin_real_dir }}/gobblin-dist/conf/gobblin-mapreduce.properties
    - pattern: '^fs.uri=hdfs://localhost:8020$'
    - repl: 'fs.uri=hdfs://{{ namenode }}:8020'
    - require:
      - archive: gobblin-dl-and-extract

gobblin-create_gobblin_jobs_directory:
  file.directory:
    - name: {{ gobblin_link_dir }}/configs
    - makedirs: True

gobblin-install_gobblin_pnda_job_file:
  file.managed:
    - name: {{ gobblin_link_dir }}/configs/mr.pull
    - source: salt://gobblin/templates/mr.pull.tpl
    - template: jinja
    - context:
      namenode: {{ namenode }}
      kite_dataset_uri: {{ pnda_kite_dataset_uri }}
      quarantine_kite_dataset_uri: {{ pnda_quarantine_kite_dataset_uri }}
      kafka_brokers: {{ kafka_brokers }}
      max_mappers: {{ flavor_cfg.max_mappers }}
    - require:
      - file: gobblin-create_gobblin_jobs_directory

gobblin-install_gobblin_upstart_script:
  file.managed:
    - name: /etc/init/gobblin.conf
    - source: salt://gobblin/templates/gobblin.conf.tpl
    - template: jinja
    - context:
      gobblin_directory_name: {{ gobblin_link_dir }}/gobblin-dist
      gobblin_user: {{ pnda_user }}
      gobblin_work_dir: {{ gobblin_hdfs_work_dir }}
      gobblin_job_file: {{ gobblin_link_dir }}/configs/mr.pull

gobblin-add_gobblin_crontab_entry:
  cron.present:
    - identifier: GOBBLIN
    - name: /sbin/start gobblin
    - user: root
    - minute: 0,30
    - require:
      - file: gobblin-install_gobblin_upstart_script
