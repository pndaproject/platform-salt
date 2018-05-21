# Install httpfs, note no need to specify version as it comes from the hdp repo mirror
hdp-httpfs_pkg:
  pkg.installed:
    - name: hadoop-httpfs
    - ignore_epoch: True

hdp-httpfs_java_home:
  file.append:
    - name: /etc/hadoop-httpfs/conf/httpfs-env.sh
    - text:
      - "export JAVA_HOME=/usr/lib/jvm/java-8-oracle/"

hdp-httpfs_service_add_file:
  file.managed:
    - name: /usr/hdp/current/hadoop-httpfs/usr/lib/systemd/system/hadoop-httpfs.service
    - source: salt://hdp/files/hadoop-httpfs.service

hdp-httpfs_service_started:
  service.running:
    - name: hadoop-httpfs
    - enable: True
    - reload: True







