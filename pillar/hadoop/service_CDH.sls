hadoop_services:
  hbase_master:
    service: hbase01
    component: MASTER
  hdfs_namenode:
    service: hdfs01
    component: NAMENODE
  hive_server:
    service: hive01
    component: HIVESERVER2
    port: 10000
  hue_server:
    service: hue01
    component: HUE_SERVER
  impala_catalog_server:
    service: impala01 
    component: IMPALAD
  oozie_server:
    service: oozie01
    component: OOZIE_SERVER
  spark_job_histroy_server:
    service: spark_on_yarn
    component: SPARK_YARN_HISTORY_SERVER
    port: 18088
  spark2_job_histroy_server:
    service: spark_on_yarn
    component: SPARK_YARN_HISTORY_SERVER
    port: 18088
  yarn_resource_manager:
    service: yarn01
    component: RESOURCEMANAGER
  yarn_job_histroy_server:
    service: yarn01
    component: JOBHISTORY
  zookeeper_server:
    service: zk01
    component: SERVER
