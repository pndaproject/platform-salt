logstash:
  version: 6.2.1

kibana:
  version: 6.2.1-linux-x86_64
  directory: /opt/pnda

elasticsearch:
  version: 6.2.1
  directory: /opt/pnda
  logdir: /var/log/elasticsearch
  confdir: /etc/elasticsearch
  workdir: /tmp/elasticsearch

zookeeper:
  version: 3.4.11

kafka:
  version: 0.11.0.2
  internal_port: 9092
  replication_port: 9093
  ingest_port: 9094

consul:
  service: True
  version: 1.0.3
  node: node

kafkatool:
  release_version: v0.2.0
  config_dir: '/etc'
  release_dir: '/opt/pnda'

admin_login:
  user: admin
  password: admin

kafkamanager:
  release_directory: /opt/pnda
  release_version: 1.3.3.15
  bind_port: 10900

jupyterproxy:
  release_version: 1.3.1

gobblin:
  release_version: 0.11.0

flink:
  release_version: 1.4.0
  historyserver_web_port: 8082
  jobmanager_web_port: 8083

platform_gobblin_modules:
  release_version: develop

console_frontend:
  release_version: develop

console_backend_data_logger:
  release_version: develop
  bind_port: 3001

console_backend_data_manager:
  release_version: develop
  bind_port: 3123

console_backend_utils:
  release_version: develop

deployment_manager:
  release_version: develop
  keys_directory: /opt/pnda/dm_keys
  admin_user: pnda

package_repository:
  release_version: develop

data-service:
  release_version: develop

hdfs_cleaner:
  release_version: develop

platform_testing:
  release_directory: /opt/pnda
  release_version: develop

platformlib:
  release_version: develop
  target_directory: "/opt/pnda"

resource_manager:
  path: /opt/pnda/rm-wrapper
  policy_file: yarn-policy.sh

jmxproxy:
  release_version: "3.2.0"
  release_hash: "sha512=97e69d7922f6515bc5ecaa9ab7326e2d61d275dd8d419bdb2fb246ec36dbc21cb8df45881a991623f1a8785744a618198094f16f37d5b66f3029516d8824b7a1"

anaconda:
  bundle_version: "5.1.0"

java:
  version: "jdk-8u131-linux-x64"
  version_name: "jdk1.8.0_131"
  source_url: "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"

cloudera:
  hadoop_version: "2.6.0-cdh5.12.1"
  parcel_repo: "http://archive.cloudera.com/cdh5/parcels/5.12.1/"
  parcel_version: "5.12.1-1.cdh5.12.1.p0.3"

hdp:
  hadoop_version: "2.7.3.2.6.4.0-91"

hadoop_manager:
  cmdb:
    user: scm
    password: scm
    database: scm

livy:
  release_version: "0.3.0"

nodejs:
  version: 'node-v6.10.2-linux-x64'

knox:
  release_version: "1.0.0"
  authentication: "internal"
  master_secret: "secret"
