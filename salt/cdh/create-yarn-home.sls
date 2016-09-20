cdh-create_hdfs_yarn_home:
  cmd.run:
    - name: sudo -u hdfs hdfs dfs -mkdir /user/yarn; sudo -u hdfs hdfs dfs -chown yarn /user/yarn
    - unless: sudo -u hdfs hdfs dfs -test -d /user/yarn

