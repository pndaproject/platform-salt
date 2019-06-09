{
  "helpTopics": {
    "/": {
      "title": "Console",
      "body": ["The PNDA console provides a real-time overview of all components in a cluster.",
        "Components are displayed in green if everything is functioning properly, yellow if there is a warning, or red if there is an error.",
        "Click the (i) next to a component for more detailed metrics, the (?) for additional help, and the gear icon to configure the component."],
      "link": "http://pnda.io/pnda-guide/console/"
    },
    "/metrics": {
      "title": "Metrics",
      "body": ["The metrics page lists the metrics for all components.",
        "You can filter the list by typing part of a metric name into the search field.",
        "The page will show a summary of all health metrics that are in a warning or error state."],
      "link": "http://pnda.io/pnda-guide/console/metrics.html"
    },
    "/packages": {
      "title": "Packages",
      "body": ["Packages are independently deployable units of application layer functionality.",
        "The deployed packages section shows packages that have been deployed. Click the Undeploy button to undeploy a package.",
        "The available packages section shows packages that are available. Click a package to start deploying it."],
      "link": "http://pnda.io/pnda-guide/console/packages.html"
    },
    "/applications": {
      "title": "Applications",
      "body": ["The apps page lets you create and manage applications, which are instances of packages. You can see the status of each application, and start or stop them.",
        "Click an application for more detailed information. There are tabs that show the overview, deployment properties, logs, statistics and metrics (application key performance indicators, or KPIs)."],
      "link": "http://pnda.io/pnda-guide/console/applications.html"
    },
    "/datasets": {
      "title": "Datasets",
      "body": ["The datasets page lets you manage the data retention policy of each dataset in the cluster.",
        "Set the mode to archive or delete to control what happens to excess data.",
        "Choose a policy to limit data by age or size, or have no limit.",
        "Set the limit to the maximum age in days, or size in gigabytes."],
      "link": "http://pnda.io/pnda-guide/console/datasets.html"
    },
    "kafka.health": {
      "body": ["Apache Kafka is a high-throughput, distributed, publish-subscribe messaging system.",
        "In PNDA, it is used to collect data ready for processing. It decouples data aggregation (publishers) from data analysis (consumers), allowing any application to consume data present on Kafka.",
        "This box shows the list of active Kafka topics.",
        "Use the Kafka manager to create and manage topics."],
      "link": "http://kafka.apache.org",
      "version": "{{ kafka_version }}"
    },
    "zookeeper.health": {
      "body": ["Apache Zookeeper provides an open source distributed configuration service, synchronization service, and naming registry for large distributed systems.",
        "It is used by Kafka for coordination of its distributed operation, to track leadership and to store topic metadata."],
      "link": "http://zookeeper.apache.org",
      "version": "{{ zookeeper_version }}"
    },
    "hadoop.SPARK_ON_YARN.health": {
      "body": ["Apache Spark is a framework and engine for distributed, large scale data processing.",
        "In PNDA, it allows for both batch mode and streaming computation."],
      "link": "http://spark.apache.org",
      "version": "{{ spark_version }}"
    },
     "flink.health": {
      "body": ["Apache Flink is an open-source stream processing framework for distributed, high-performing, always-available, and accurate data streaming applications.",
        "In PNDA, it allows for both batch mode and streaming computation."],
      "link": "http://flink.apache.org/",
      "version": "{{ flink_version }}"
    },
    "hadoop.OOZIE.health": {
      "body": ["Apache Oozie is a workflow scheduler system to manage Apache Hadoop jobs.",
        "In PNDA, batch mode Spark jobs are run on a regular schedule by Oozie."],
      "link": "https://oozie.apache.org",
      "version": "{{ oozie_version }}"
    },
    "hadoop.YARN.health": {
      "body": ["Apache Hadoop YARN (Yet Another Resource Negotiator) is a cluster management technology.",
        "It coordinates running of jobs and their component tasks on a cluster, allocating memory and cores to those tasks.",
        "This component shows the amount of memory used, and the number of virtual cores used."],
      "link": "http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html",
      "version": "{{ yarn_version }}"
    },
    "hadoop.IMPALA.health": {
      "body": ["Apache Impala is a parallel execution engine for SQL queries. It supports low-latency access and interactive exploration of data in HDFS and HBase.",
        "Impala allows data to be stored in a raw form in HDFS and HBase, with aggregation performed at query time without requiring upfront aggregation of data.",
        "Impala is only available with the Cloudera distribution of Hadoop."],
      "link": "http://impala.io"
    },
     "opentsdb.health": {
      "body": ["OpenTSDB is a scalable time series database that lets you store and serve massive amounts of time series data, without losing granularity.",
        "In PNDA, a custom application (reading data from Kafka or HDFS for example) could write time series and store them in OpenTSDB."],
      "link": "http://opentsdb.net/",
      "version": "{{ opentsdb_version }}"
    },
    "hadoop.HQUERY.health": {
      "body": ["Apache Hive is a parallel execution engine for SQL queries. It supports low-latency access and interactive exploration of data in HDFS and HBase.",
        "Hive allows data to be stored in a raw form in HDFS and HBase, with aggregation performed at query time without requiring upfront aggregation of data."],
      "link": "https://hive.apache.org/",
      "version": "{{ hive_version }}"
    },
    "hadoop.HBASE.health": {
      "body": ["HBase is a distributed, scalable key-value data store, designed for fast, random access to very large data sets, i.e. millions of columns and billions of rows.",
        "In PNDA, a custom application (reading data from Kafka or HDFS for example) could write arbitrary key/value data into HBase."],
      "link": "http://hbase.apache.org",
      "version": "{{ hbase_version }}"
    },
    "hadoop.HIVE.health": {
      "body": ["The Hive metastore service stores the metadata for Hive tables and partitions in a relational database, and provides clients access to this information via the metastore service API.",
        "In PNDA, the Hive metastore sits on top of HDFS to provide a relational schema mapping that allows data to be queried through Impala."],
      "link": "https://cwiki.apache.org/confluence/display/Hive/AdminManual+MetastoreAdmin",
      "version": "{{ hive_version }}"
    },
    "hadoop.HDFS.health": {
      "body": ["HDFS is a fault tolerant and self-healing distributed file system, suited to large-scale data processing workloads.",
        "In PNDA, gobblin runs every half an hour to copy all data from Kafka into the master dataset in HDFS. The master dataset is a historical store of all data. Applications can also output data in HDFS."],
      "link": "https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html",
      "version": "{{ hdfs_version }}" 
    },
    "deployment-manager.health": {
      "body": ["The deployment manager manages packages and applications on PNDA.",
        "Packages are archives containing the program binaries and configuration files for a specific task.",
        "Applications instances are created from packages."],
      "link": "http://pnda.io/pnda-guide/repos/platform-deployment-manager/"
    },
    "hadoop.CLUSTER_MANAGER.health": {
      "body": ["The cluster manager is provided as part of the Hadoop distribution. It monitors all the hosts and services that make up the cluster."],
      "link": {
        "CDH": "https://www.cloudera.com/products/product-components/cloudera-manager.html",
        "HDP": "https://ambari.apache.org/"
      }
    }
  }
}
