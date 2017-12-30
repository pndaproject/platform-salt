{% set pnda_user  = pillar['pnda']['user'] %}
{% set pnda_group = pillar['pnda']['group'] %}

{% set namenode = salt['pnda.hadoop_namenode']() %}

{% set pnda_master_dataset_location = pillar['pnda']['master_dataset']['directory'] %}
{% set pnda_kite_dataset_uri = "dataset:" + namenode + pnda_master_dataset_location %}

{% set pnda_master_bulk_location = pillar['pnda']['master_dataset']['bulk_directory'] %}

{% set pnda_quarantine_dataset_location = pillar['pnda']['master_dataset']['quarantine_directory'] %}
{% set pnda_quarantine_kite_dataset_uri = "dataset:" + namenode + pnda_quarantine_dataset_location %}

{% set pnda_staging_dataset_location = pillar['pnda']['master_dataset']['staging_directory'] %}
{% set pnda_kite_staging_dataset_uri = "dataset:" + namenode + pnda_staging_dataset_location %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set kite_package = 'kite-tools-1.0.0-binary.jar' %}
{% set kite_install_path = '/opt/pnda/kite-sdk/' %}
{% set kite_tool_wrapper = '/usr/bin/kite-dataset' %}

include:
  - .pnda_hdfs_user

master-dataset_copy_pnda_avro_schema:
  file.managed:
    - name: /tmp/pnda.avsc
    - source: salt://master-dataset/files/pnda.avsc

master-dataset_copy_kite_parition_conf:
  file.managed:
    - name: /tmp/pnda_kite_partition.json
    - source: salt://master-dataset/files/pnda_kite_partition.json

{% if grains['hadoop.distro'] == 'HDP' %}
master-dataset-kitesdk_dir:
  file.directory:
    - name: {{ kite_install_path }}
    - makedirs: True

master-dataset-kitesdk_dl:
  file.managed:
    - name: {{ kite_install_path }}{{ kite_package }}
    - mode: 0755
    - source: {{ mirror_location }}/{{ kite_package }}
    - source_hash: {{ mirror_location }}/{{ kite_package }}.sha1

master-dataset-kitesdk_path:
  cmd.run:
    - name: printf '#!/usr/bin/env bash\nexport HADOOP_HOME=/usr/hdp/current/hadoop-client/\n{{ kite_install_path }}{{ kite_package }} $@' > {{ kite_tool_wrapper }}

master-dataset-kitesdk_perms:
  file.managed:
    - name: {{ kite_tool_wrapper }}
    - mode: 755
    - replace: False
{% endif %}

master-dataset-create_PNDA_master_kite_dataset:
  cmd.run:
    - name: kite-dataset create --schema /tmp/pnda.avsc {{ pnda_kite_dataset_uri }} --partition-by /tmp/pnda_kite_partition.json
    - user: {{ pnda_user }}
    - unless: kite-dataset info {{ pnda_kite_dataset_uri }}
    - requires:
      - file: master-dataset_copy_pnda_avro_schema
      - file: master-dataset_copy_kite_parition_conf

master-dataset-update_PNDA_master_kite_dataset_perms:
  cmd.run:
    - name: hdfs dfs -chmod 770 {{ pnda_master_dataset_location }}
    - user: hdfs
    - onchanges:
      - cmd: master-dataset-create_PNDA_master_kite_dataset

{%if salt['pillar.get']('dataset_compaction:compaction', False) %}
master-dataset-create_PNDA_staging_kite_dataset:
  cmd.run:
    - name: kite-dataset create --schema /tmp/pnda.avsc {{ pnda_kite_staging_dataset_uri }} --partition-by /tmp/pnda_kite_partition.json
    - user: {{ pnda_user }}
    - unless: kite-dataset info {{ pnda_kite_staging_dataset_uri }}
    - requires:
      - file: master-dataset_copy_pnda_avro_schema
      - file: master-dataset_copy_kite_parition_conf

master-dataset-update_PNDA_staging_kite_dataset_perms:
  cmd.run:
    - name: hdfs dfs -chmod 770 {{ pnda_staging_dataset_location }}
    - user: hdfs
    - onchanges:
      - cmd: master-dataset-create_PNDA_staging_kite_dataset
{% endif %}

master-dataset-quarantine_dataset_copy_avro_schema:
  file.managed:
    - name: /tmp/quarantine.avsc
    - source: salt://master-dataset/files/quarantine.avsc

master-dataset-quarantine_dataset_copy_kite_partition:
  file.managed:
    - name: /tmp/pnda_quarantine_kite_partition.json
    - source: salt://master-dataset/files/pnda_quarantine_kite_partition.json

master-dataset-create_PNDA_error_kite_dataset:
  cmd.run:
    - name: kite-dataset create --schema /tmp/quarantine.avsc {{ pnda_quarantine_kite_dataset_uri }} --partition-by /tmp/pnda_quarantine_kite_partition.json
    - user: {{ pnda_user }}
    - unless: kite-dataset info {{ pnda_quarantine_kite_dataset_uri }}
    - requires:
      - file: master-dataset-quarantine_dataset_copy_avro_schema
      - file: master-dataset-quarantine_dataset_copy_kite_partition

master-dataset-update_PNDA_quarantine_dataset_perms:
  cmd.run:
    - name: hdfs dfs -chmod 770 {{ pnda_quarantine_dataset_location }}
    - user: hdfs
    - onchanges:
      - cmd: master-dataset-create_PNDA_error_kite_dataset

master-bulk-ingest:
  cmd.run:
    - name: hdfs dfs -mkdir {{ pnda_master_bulk_location }}
    - user: {{ pnda_user }}
    - unless: hdfs dfs -test -d {{ pnda_master_bulk_location }}

master-bulk-ingest-perms:
  cmd.run:
    - name: hdfs dfs -chmod 770 {{ pnda_master_bulk_location }}
    - user: hdfs
    - onchanges:
      - cmd: master-bulk-ingest
