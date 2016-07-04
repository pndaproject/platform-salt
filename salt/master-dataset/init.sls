{% set pnda_user  = pillar['pnda']['user'] %}
{% set pnda_group = pillar['pnda']['group'] %}

{% set namenodes_ips = salt['pnda.namenodes_ips']() %}
# Only take the first one
{% set namenode = namenodes_ips[0] %}

{% set pnda_master_dataset_location = pillar['pnda']['master_dataset']['directory'] %}
{% set pnda_kite_dataset_uri = "dataset:hdfs://" + namenode + ":8020" + pnda_master_dataset_location %}

{% set pnda_quarantine_dataset_location = pillar['pnda']['master_dataset']['quarantine_directory'] %}
{% set pnda_quarantine_kite_dataset_uri = "dataset:hdfs://" + namenode + ":8020" + pnda_quarantine_dataset_location %}

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

master-dataset-create_PNDA_master_kite_dataset:
  cmd.run:
    - name: kite-dataset create --schema /tmp/pnda.avsc {{ pnda_kite_dataset_uri }} --partition-by /tmp/pnda_kite_partition.json
    - user: {{ pnda_user }}
    - unless: kite-dataset info {{ pnda_kite_dataset_uri }}

master-dataset-update_PNDA_master_kite_dataset_perms:
  cmd.run:
    - name: hdfs dfs -chmod 770 {{ pnda_master_dataset_location }}
    - user: hdfs
    - onchanges:
      - cmd: master-dataset-create_PNDA_master_kite_dataset

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

master-dataset-update_PNDA_quarantine_dataset_perms:
  cmd.run:
    - name: hdfs dfs -chmod 770 {{ pnda_quarantine_dataset_location }}
    - user: hdfs
    - onchanges:
      - cmd: master-dataset-create_PNDA_error_kite_dataset

master-bulk-ingest:
  cmd.run:
    - name: sudo -u hdfs hdfs dfs -mkdir /user/pnda/PNDA_datasets/bulk/
    - unless: sudo -u hdfs hdfs dfs -test -d /user/pnda/PNDA_datasets/bulk/
