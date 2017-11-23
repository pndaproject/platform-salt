logstash:
  version: 5.2.2

kibana:
  version: 4.1.6-linux-x64
  directory: /opt/pnda

elasticsearch:
  version: 1.5.0
  directory: /opt/pnda
  logdir: /var/log/elasticsearch
  confdir: /etc/elasticsearch
  workdir: /tmp/elasticsearch

elasticsearch-cluster:
  version: 5.0.0
  name: pnda-cluster
  directory: /opt/pnda
  logdir: /var/log/elasticsearch
  datadir: /var/lib/elasticsearch
  workdir: /tmp/elasticsearch

logstash-cluster:
  version: 5.2.2
  directory: /opt/pnda
  logdir: /var/log/logstash
  confdir: /etc/logstash
  datadir: /var/lib/logstash
  inputdir: /tmp/logstash

zookeeper:
  version: 3.4.6

kafka:
  version: 0.11.0.0
  internal_port: 9092
  replication_port: 9093
  ingest_port: 9094

kafkatool:
  release_version: v0.2.0
  config_dir: '/etc'
  release_dir: '/opt/pnda'

admin_login:
  user: admin
  password: admin

kafkamanager:
  release_directory: /opt/pnda
  release_version: 1.3.3.6
  bind_port: 10900

jupyterproxy:
  release_version: 1.3.1

gobblin:
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

jmxproxy:
  release_version: "3.2.0"
  release_hash: "sha512=97e69d7922f6515bc5ecaa9ab7326e2d61d275dd8d419bdb2fb246ec36dbc21cb8df45881a991623f1a8785744a618198094f16f37d5b66f3029516d8824b7a1"

anaconda:
  parcel_version: "4.0.0"
  parcel_repo: "https://repo.continuum.io/pkgs/misc/parcels/"

java:
  version: "jdk-8u131-linux-x64"
  version_name: "jdk1.8.0_131"
  source_url: "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"

cloudera:
  parcel_repo: "http://archive.cloudera.com/cdh5/parcels/5.12.1/"
  parcel_version: "5.12.1-1.cdh5.12.1.p0.3"

hadoop_manager:
  cmdb:
    user: scm
    password: scm
    database: scm
