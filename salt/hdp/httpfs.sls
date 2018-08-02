# Install httpfs, note no need to specify version as it comes from the hdp repo mirror
hdp-httpfs_pkg:
  pkg.installed:
    - name: hadoop-httpfs
    - ignore_epoch: True

hdp-httpfs_hadoop_tmp_directory:
  file.directory:
    - name: /mnt/hadoop-tmp/httpfs
    - makedirs: True
    - user: httpfs
    - group: httpfs
    - mode: 755

hdp-httpfs_pnda_log_directory:
  file.directory:
    - name: /var/log/pnda/httpfs
    - makedirs: True
    - user: httpfs
    - group: httpfs
    - mode: 755

/etc/hadoop-httpfs/conf/httpfs-signature.secret:
  file.touch

/usr/lib/systemd/system/hadoop-httpfs.service:
  file.managed:
    - source: salt://hdp/templates/hadoop-httpfs.service.tpl
    - mode: 644
    - template: jinja

hdp-httpfs_service_started:
  service.running:
    - name: hadoop-httpfs
    - enable: True
    - reload: True
