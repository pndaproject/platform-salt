# Install httpfs, note no need to specify version as it comes from the hdp repo mirror
hdp-apt-debug1:
  cmd.run:
    - name: ps aux | grep apt

hdp-apt-debug2:
  cmd.run:
    - name: ps aux | grep salt-minion

hdp-httpfs_pkg:
  pkg.installed:
    - name: hadoop-httpfs
    - ignore_epoch: True

hdp-httpfs_create_link:
  file.symlink:
    - name: /etc/init.d/hadoop-httpfs
    - target: /usr/hdp/current/hadoop-httpfs/etc/init.d/hadoop-httpfs

hdp-httpfs_java_home:
  cmd.run:
    - name: echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle/' >> /etc/hadoop-httpfs/conf/httpfs-env.sh

hdp-httpfs_service_started:
  service.running:
    - name: hadoop-httpfs
    - enable: True
    - reload: True


