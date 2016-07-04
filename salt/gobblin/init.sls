{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set gobblin_user = "gobblin" %}
{% set gobblin_version = pillar['gobblin']['release_version'] %}
{% set gobblin_package = 'gobblin-distribution-' + gobblin_version + '.tar.gz' %}
{% set gobblin_real_dir = '/home/' + gobblin_user + '/gobblin-' + gobblin_version %}
{% set gobblin_link_dir = '/home/' + gobblin_user + '/gobblin' %}

{% set pnda_group = pillar['pnda']['group'] %}

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

{% set gobblin_work_dir = '/user/gobblin/work' %}

include:
  - .user

gobblin-create_hdfs_gobblin_home:
  cmd.run:
    - name: sudo -u hdfs hdfs dfs -mkdir /user/{{ gobblin_user }} && sudo -u hdfs hdfs dfs -chown {{ gobblin_user }} /user/{{ gobblin_user }}
    - unless: sudo -u hdfs hdfs dfs -test -d /user/{{ gobblin_user }}

gobblin-create_gobblin_version_directory:
  file.directory:
    - name: {{ gobblin_real_dir }}
    - user: {{ gobblin_user }}
    - group: {{ gobblin_user }}
    - makedirs: True

gobblin-dl-and-extract:
  archive.extracted:
    - name: {{ gobblin_real_dir }}
    - source: {{ packages_server }}/platform/releases/gobblin/{{ gobblin_package }}
    - source_hash: {{ packages_server }}/platform/releases/gobblin/{{ gobblin_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - user: {{ gobblin_user }}
    - group: {{ gobblin_user }}
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
    - name: /home/{{ gobblin_user }}/configs
    - user: {{ gobblin_user }}
    - makedirs: True

gobblin-install_gobblin_pnda_job_file:
  file.managed:
    - name: /home/{{ gobblin_user }}/configs/mr.pull
    - source: salt://gobblin/templates/mr.pull.tpl
    - template: jinja
    - context:
      namenode: {{ namenode }}
      kite_dataset_uri: {{ pnda_kite_dataset_uri }}
      quarantine_kite_dataset_uri: {{ pnda_quarantine_kite_dataset_uri }}
      kafka_brokers: {{ kafka_brokers }}

gobblin-install_gobblin_upstart_script:
  file.managed:
    - name: /etc/init/gobblin.conf
    - source: salt://gobblin/templates/gobblin.conf.tpl
    - template: jinja
    - context:
      gobblin_directory_name: {{ gobblin_link_dir }}/gobblin-dist
      gobblin_user: {{ gobblin_user }}
      gobblin_work_dir: {{ gobblin_work_dir }}

gobblin-add_gobblin_crontab_entry:
  cron.present:
    - identifier: GOBBLIN
    - name: /sbin/start gobblin
    - user: root
    - minute: 0,30
