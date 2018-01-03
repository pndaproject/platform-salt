{% set pnda_user  = pillar['pnda']['user'] %}
{% set pnda_group = pillar['pnda']['group'] %}

master-dataset-create_hdfs_pnda_home:
  cmd.run:
    - name: hdfs dfs -mkdir /user/{{ pnda_user }} && hdfs dfs -chown {{ pnda_user }}:{{ pnda_group }} /user/{{ pnda_user }} && hdfs dfs -chmod 770 /user/{{ pnda_user }}
    - user: hdfs
    - unless: hdfs dfs -test -d /user/{{ pnda_user }}

{% if pillar['identity']['pam_module'] == 'pam_unix' %}

{% for usr in pillar['identity']['users'] %}

{% set user = usr['user'] %}
{% set group = usr['group'] %}

master-dataset-create_hdfs_{{ user }}_home:
  cmd.run:
    - name: hdfs dfs -mkdir /user/{{ user }} && hdfs dfs -chown {{ user }}:{{ group }} /user/{{ user }} && hdfs dfs -chmod 770 /user/{{ user }}
    - user: hdfs
    - unless: hdfs dfs -test -d /user/{{ user }}

{% endfor %}
{% endif %}
