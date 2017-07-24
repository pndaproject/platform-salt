cdh-create_hdfs_yarn_home:
  cmd.run:
    - name: sudo -u hdfs hdfs dfs -mkdir /user/yarn; sudo -u hdfs hdfs dfs -chown yarn /user/yarn
    - unless: sudo -u hdfs hdfs dfs -test -d /user/yarn

cdh-create_hdfs_hdfs_home:
  cmd.run:
    - name: sudo -u hdfs hdfs dfs -mkdir /user/hdfs; sudo -u hdfs hdfs dfs -chown hdfs /user/hdfs
    - unless: sudo -u hdfs hdfs dfs -test -d /user/hdfs

