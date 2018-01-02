{% set pnda_cluster = salt['environ.get']('CLUSTER') %}

{% if grains['hadoop.distro'] == 'CDH' %}
orchestrate-pnda-run_cloudera_user:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:*'
    - tgt_type: compound
    - sls: cdh.cloudera_user
    - timeout: 120
    - queue: True

orchestrate-pnda-install_hadoop_manager:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: cdh.cloudera-manager
    - timeout: 120
    - queue: True

orchestrate-pnda-install-agents:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:*'
    - tgt_type: compound
    - sls: cdh.cloudera-manager-agent
    - timeout: 120
    - queue: True

orchestrate-pnda-install_cdh_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: cdh.setup_hadoop
    - timeout: 120
    - queue: True

orchestrate-pnda-impala_wrapper:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:impala-shell'
    - tgt_type: compound
    - sls: cdh.impala-shell
    - timeout: 120
    - queue: True

orchestrate-pnda-hue_setup:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:MGR*'
    - tgt_type: compound
    - sls: cdh.hue-login
    - timeout: 120
    - queue: True
{% endif %}

{% if grains['hadoop.distro'] == 'HDP' %}
orchestrate-pnda-install_ambari_server:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: ambari.server
    - timeout: 120
    - queue: True

orchestrate-pnda-install_ambari_agents:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:*'
    - tgt_type: compound
    - sls: ambari.agent
    - timeout: 120
    - queue: True

orchestrate-pnda-install_hdp_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: hdp.setup_hadoop
    - timeout: 120
    - queue: True

orchestrate-pnda-install_hdp_hadoop_hbase_rest:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:role:MGR01'
    - tgt_type: compound
    - sls: hdp.hbase_rest
    - timeout: 120
    - queue: True

orchestrate-pnda-install_hdp_hadoop_hbase_thrift:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:role:MGR01'
    - tgt_type: compound
    - sls: hdp.hbase_thrift
    - timeout: 120
    - queue: True

orchestrate-pnda-install_hdp_hadoop_httpfs:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:role:MGR01'
    - tgt_type: compound
    - sls: hdp.httpfs
    - timeout: 120
    - queue: True
{% endif %}

orchestrate-pnda-create_master_dataset:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:master_dataset'
    - tgt_type: compound
    - sls: master-dataset
    - timeout: 120
    - queue: True

orchestrate-pnda-install_spark_wrapper:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and ( G@hadoop:* or G@roles:jupyter )'
    - tgt_type: compound
    - sls: resource-manager
    - timeout: 120
    - queue: True

orchestrate-pnda-install_gobblin:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:gobblin'
    - tgt_type: compound
    - sls: gobblin
    - timeout: 120
    - queue: True

orchestrate-pnda-install_platform_libraries:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:*'
    - tgt_type: compound
    - sls: pnda.platform-libraries
    - timeout: 120
    - queue: True

orchestrate-pnda-install_jupyter:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:jupyter'
    - tgt_type: compound
    - sls: jupyter
    - timeout: 120
    - queue: True

orchestrate-pnda-configure_yarn_for_spark:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:yarn-gateway'
    - tgt_type: compound
    - sls: cdh.create-yarn-home
    - timeout: 120
    - queue: True

orchestrate-pnda-install_deployment_manager:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:deployment_manager'
    - tgt_type: compound
    - sls: deployment-manager
    - timeout: 120
    - queue: True

orchestrate-pnda-install_deployment_manager_keys:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and ( G@hadoop:* or G@roles:opentsdb )'
    - tgt_type: compound
    - sls: deployment-manager.install_keys
    - timeout: 120
    - queue: True

orchestrate-pnda-create_hbase_opentsdb_tables:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hbase_opentsdb_tables'
    - tgt_type: compound
    - sls: opentsdb.hbase_tables
    - timeout: 120
    - queue: True

orchestrate-pnda-km_create_cluster:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:kafka_manager'
    - tgt_type: compound
    - sls: kafka-manager.pnda_create_cluster
    - timeout: 120
    - queue: True

orchestrate-pnda-install_data_service:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:data_service'
    - tgt_type: compound
    - sls: data-service
    - timeout: 120
    - queue: True

orchestrate-pnda-install_opentsdb:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:opentsdb'
    - tgt_type: compound
    - sls: pnda_opentsdb.conf
    - timeout: 120
    - queue: True

orchestrate-pnda-install_hdfs_cleaner:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hdfs_cleaner'
    - tgt_type: compound
    - sls: hdfs-cleaner
    - timeout: 120
    - queue: True

orchestrate-pnda-kafka_create_topics:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:kafka and G@broker_id:0'
    - tgt_type: compound
    - sls: platform-testing.create_topic
    - timeout: 120
    - queue: True

orchestrate-pnda-data_service-create_datasets:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:data_service'
    - tgt_type: compound
    - sls: data-service.create_datasets
    - timeout: 120
    - queue: True

orchestrate-pnda-install_test_modules:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:platform_testing_cdh'
    - tgt_type: compound
    - sls: platform-testing.cdh
    - timeout: 120
    - queue: True

{% if grains['hadoop.distro'] == 'HDP' %}
orchestrate-pnda-install_hdp_hadoop_oozie_libs:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:role:EDGE'
    - tgt_type: compound
    - sls: hdp.oozie_libs
    - timeout: 120
    - queue: True
{% endif %}

orchestrate-pnda-app-packages:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and ( G@hadoop:role:EDGE or G@roles:jupyter )'
    - tgt_type: compound
    - sls: app-packages
    - timeout: 120
    - queue: True

orchestrate-pnda-install_remove_new_node_markers:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}}'
    - tgt_type: compound
    - sls: orchestrate.remove_new_node_marker
    - timeout: 120
    - queue: True

orchestrate-pnda-app-packages-hdfs-sync:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_edge'
    - tgt_type: compound
    - sls: app-packages.hdfs-sync
    - timeout: 120
    - queue: True

orchestrate-pnda-initial_gobblin_run:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:gobblin'
    - tgt_type: compound
    - sls: gobblin.initial_gobblin_run
    - timeout: 120
    - queue: True

orchestrate-saltstack_minion_config:
  salt.state:
    - tgt: '*'
    - tgt_type: compound
    - sls: config
    - timeout: 120
    - queue: True

orchestrate-pnda_vm_reboot:
  salt.state:
    - tgt: '*'
    - tgt_type: compound
    - sls: reboot.kernel_reboot
    - timeout: 120
    - queue: True
