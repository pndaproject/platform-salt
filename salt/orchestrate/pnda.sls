{% set pnda_cluster = salt['environ.get']('CLUSTER') %}

cdh-run_cloudera_user:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_*'
    - tgt_type: compound
    - sls: cdh.cloudera_user

cdh-install_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_manager'
    - tgt_type: compound
    - sls: cdh.setup_hadoop

cdh-create_master_dataset:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_edge'
    - tgt_type: compound
    - sls: master-dataset

cdh-impala_wrapper:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_edge'
    - tgt_type: compound
    - sls: cdh.impala-shell

cdh-hue_setup:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@cloudera:role:MGR04'
    - tgt_type: compound
    - sls: cdh.hue-login

# We need to create the gobblin user on the namenode to have the HDFS mapping
# between user and groups
cdh-create_gobblin_user_on_namenodes:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_*'
    - tgt_type: compound
    - sls: gobblin.user

cdh-install_gobblin:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:gobblin'
    - tgt_type: compound
    - sls: gobblin

cdh-install_jupyter:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:jupyter'
    - tgt_type: compound
    - sls: jupyter

cdh-configure_yarn_for_spark:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_edge'
    - tgt_type: compound
    - sls: cdh.yarn

cdh-install_deployment_manager:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:deployment_manager'
    - tgt_type: compound
    - sls: deployment-manager

cdh-install_deployment_manager_keys:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}}'
    - tgt_type: compound
    - sls: deployment-manager.keys

cdh-install_package_repository:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:package_repository'
    - tgt_type: compound
    - sls: package-repository

cdh-create_hbase_opentsdb_tables:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_edge'
    - tgt_type: compound
    - sls: opentsdb.hbase_tables

km-create_cluster:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:tools'
    - tgt_type: compound
    - sls: kafka-manager.pnda_create_cluster

cdh-install_data_service:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:data_service'
    - tgt_type: compound
    - sls: data-service

cdh-install_opentsdb:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:opentsdb'
    - tgt_type: compound
    - sls: pnda_opentsdb.conf

cdh-install_hdfs_cleaner:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_edge'
    - tgt_type: compound
    - sls: hdfs-cleaner

kafka-create_topics:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:kafka and G@broker_id:0'
    - tgt_type: compound
    - sls: platform-testing.create_topic

cdh-data_service-create_datasets:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:data_service'
    - tgt_type: compound
    - sls: data-service.create_datasets

