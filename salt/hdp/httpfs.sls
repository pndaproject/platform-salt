# Install httpfs, note no need to specify version as it comes from the hdp repo mirror
hdp-httpfs_pkg:
  pkg.installed:
    - name: hadoop-httpfs
    - ignore_epoch: True

hdp-httpfs_create_link:
  file.symlink:
    - name: /etc/init.d/hadoop-httpfs
    - target: /usr/hdp/current/hadoop-httpfs/etc/init.d/hadoop-httpfs

hdp-httpfs_java_home:
  file.append:
    - name: /etc/hadoop-httpfs/conf/httpfs-env.sh
    - text:
      - "export JAVA_HOME=/usr/lib/jvm/java-8-oracle/"

hdp-httpfs_service_started:
  service.running:
    - name: hadoop-httpfs
    - enable: True
    - reload: True


