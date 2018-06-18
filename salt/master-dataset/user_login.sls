{% set user = pillar['user']  %}
{% set group = pillar['group'] %}

master-dataset-create_hdfs_{{ user }}_home:
  cmd.run:
    - name: hdfs dfs -mkdir /user/{{ user }} && hdfs dfs -chown {{ user }}:{{ group }} /user/{{ user }} && hdfs dfs -chmod 770 /user/{{ user }}
    - user: hdfs
    - unless: hdfs dfs -test -d /user/{{ user }}
