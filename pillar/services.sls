mine_functions:
  network.ip_addrs: [eth0]
  grains.items: []

logstash:
  version: 1.4.2
  directory: /opt/pnda

kibana:
  version: 4.1.6-linux-x64
  directory: /opt/pnda

elasticsearch:
  version: 1.5.0
  directory: /opt/pnda
  logdir: /var/log/elasticsearch
  datadir: /var/lib/elasticsearch
  confdir: /etc/elasticsearch
  workdir: /tmp/elasticsearch

jupyter:
  version: 4.2.0
  confdir: /usr/local/etc/jupyter
  kerneldir: /usr/local/share/jupyter/kernels

jupyterhub:
  version: 0.6.1
  confdir: /etc/jupyterhub

zookeeper:
  version: 3.4.6

kafka:
  version: 0.10.0.1
  config:
    log_dirs:
      - '/var/kafka-logs'

admin_login:
  user: admin
  password: admin

kafkamanager:
  release_directory: /opt/pnda
  release_version: 1.3.1.6
  bind_port: 10900

opentsdb:
  version: 2.2.0
  release_hash: sha256=e82738703efa50cfdd42dd7741e3d5b78fc2bf8cd12352253fc1489d1dea1f60
  bind_port: 4242

grafana:
  version: 3.1.1-1470047149
  release_hash: sha256=4d3153966afed9b874a6fa6182914d9bd2e69698bbc7c13248d1b7ef09d3d328

gobblin:
  release_version: RELEASE-0.1.2

console_frontend:
  release_version: RELEASE-0.1.3

console_backend_data_logger:
  release_version: RELEASE-0.2.3
  bind_port: 3001

console_backend_data_manager:
  release_version: RELEASE-0.2.3
  bind_port: 3123

deployment_manager:
  release_version: RELEASE-0.2.1

package_repository:
  release_version: RELEASE-0.2.1

data-service:
  release_version: RELEASE-0.1.2

hdfs_cleaner:
  release_version: RELEASE-0.1.2

platform_testing:
  release_directory: /opt/pnda
  release_version: RELEASE-0.2.0

platformlib:
  release_version: RELEASE-0.1.2
  target_directory: "/opt/pnda"

jmxproxy:
  release_version: "3.2.0"
  release_hash: "sha512=97e69d7922f6515bc5ecaa9ab7326e2d61d275dd8d419bdb2fb246ec36dbc21cb8df45881a991623f1a8785744a618198094f16f37d5b66f3029516d8824b7a1"

anaconda:
  parcel_version: "4.0.0"
  parcel_repo: "https://repo.continuum.io/pkgs/misc/parcels/"
