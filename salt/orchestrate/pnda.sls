{% set pnda_cluster = salt['environ.get']('CLUSTER') %}

cdh-run_cloudera_user:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@cloudera:*'
    - tgt_type: compound
    - sls: cdh.cloudera_user
    - timeout: 120

cdh-install_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_manager'
    - tgt_type: compound
    - sls: cdh.setup_hadoop
    - timeout: 120

cdh-create_master_dataset:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:master_dataset'
    - tgt_type: compound
    - sls: master-dataset
    - timeout: 120

cdh-impala_wrapper:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:impala-shell'
    - tgt_type: compound
    - sls: cdh.impala-shell
    - timeout: 120

cdh-hue_setup:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hue'
    - tgt_type: compound
    - sls: cdh.hue-login
    - timeout: 120

cdh-install_gobblin:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:gobblin'
    - tgt_type: compound
    - sls: gobblin
    - timeout: 120

cdh-install_jupyter:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:jupyter'
    - tgt_type: compound
    - sls: jupyter
    - timeout: 120

cdh-configure_yarn_for_spark:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:yarn-gateway'
    - tgt_type: compound
    - sls: cdh.create-yarn-home
    - timeout: 120

cdh-install_deployment_manager:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:deployment_manager'
    - tgt_type: compound
    - sls: deployment-manager
    - timeout: 120

cdh-install_deployment_manager_keys:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and ( G@cloudera:* or G@roles:opentsdb )'
    - tgt_type: compound
    - sls: deployment-manager.keys
    - timeout: 120

cdh-create_hbase_opentsdb_tables:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hbase_opentsdb_tables'
    - tgt_type: compound
    - sls: opentsdb.hbase_tables
    - timeout: 120

km-create_cluster:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:kafka_manager'
    - tgt_type: compound
    - sls: kafka-manager.pnda_create_cluster
    - timeout: 120

cdh-install_data_service:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:data_service'
    - tgt_type: compound
    - sls: data-service
    - timeout: 120

cdh-install_opentsdb:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:opentsdb'
    - tgt_type: compound
    - sls: pnda_opentsdb.conf
    - timeout: 120

cdh-install_hdfs_cleaner:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hdfs_cleaner'
    - tgt_type: compound
    - sls: hdfs-cleaner
    - timeout: 120

kafka-create_topics:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:kafka and G@broker_id:0'
    - tgt_type: compound
    - sls: platform-testing.create_topic
    - timeout: 120

cdh-data_service-create_datasets:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:data_service'
    - tgt_type: compound
    - sls: data-service.create_datasets
    - timeout: 120


