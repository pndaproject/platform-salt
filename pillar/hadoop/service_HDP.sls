hadoop_services:
  hbase_master:
    service: HBASE
    component: HBASE_MASTER
  hdfs_namenode:
    service: HDFS
    component: NAMENODE
  hive_server:
    service: HIVE
    component: HIVE_SERVER
    port: 10001
  oozie_server:
    service: OOZIE
    component: OOZIE_SERVER
  spark_job_histroy_server:
    service: SPARK
    component: SPARK_JOBHISTORYSERVER
    port: 18080
  spark2_job_histroy_server:
    service: SPARK2
    component: SPARK2_JOBHISTORYSERVER
    port: 18081
  yarn_resource_manager:
    service: YARN
    component: RESOURCEMANAGER
  yarn_job_histroy_server:
    service: MAPREDUCE2
    component: HISTORYSERVER
  zookeeper_server:
    service: ZOOKEEPER
    component: ZOOKEEPER_SERVER
