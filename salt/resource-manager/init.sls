{% set resource_manager_path = pillar['resource_manager']['path'] %}
{% set map_file = resource_manager_path + "/policies/map.txt" %}
{% set policy_file_link = resource_manager_path + pillar['resource_manager']['policy_file'] %}
{% set execs = [ 'spark-submit', 'spark-shell', 'pyspark', 'mapred', 'hive', 'beeline', 'flink', 'pyflink.sh', 'start-scala-shell.sh', 'yarn-session.sh' ] %} 
{% set flink_version = pillar['flink']['release_version'] %}
{% set pnda_home = pillar['pnda']['homedir'] %}
{% set flink_bin_dir = pnda_home + '/flink-' + flink_version + '/bin' %}
{% if grains['hadoop.distro'] == 'HDP' %}
{% set map_file_source = 'capacity_scheduler_map.txt' %}
{% else %}
{% set map_file_source = 'fair_scheduler_map.txt' %}
{% endif %}

resource-manager_user-group-policy_install:
  file.managed:
    - name: {{ resource_manager_path }}/policies/yarn-user-group-policy.sh
    - source: salt://resource-manager/templates/yarn-user-group-policy.sh
    - template: jinja
    - defaults:
      map_file: {{ map_file }}
    - mode: 755
    - makedirs: True
    - dir_mode: 755

resource-manager_group_map_install:
  file.managed:
    - name: {{ map_file }}
    - source: salt://resource-manager/templates/{{ map_file_source }}
    - mode: 755

resource-manager_policy_selection:
  file.symlink:
    - name: {{ policy_file_link }}
    - target: {{ resource_manager_path }}/policies/yarn-user-group-policy.sh
    - mode: 755

resource-manager_log:
  file.managed:
    - name: '/var/log/pnda/wrapper.log'
    - user: pnda
    - group: pnda
    - mode: 666
    - makedirs: True
    - dir_mode: 755

resource-manager_spark_common_wrapper:
  file.managed:
    - name: {{ resource_manager_path }}/bin/yarn-common-wrapper.sh
    - source: salt://resource-manager/templates/yarn-common-wrapper.sh
    - template: jinja
    - defaults:
        resource_manager_path: {{ resource_manager_path }}
        policy_file_link: {{ policy_file_link }}
        log_file: '/var/log/pnda/wrapper.log'
    - mode: 755
    - makedirs: True

resource-manager_profile_sh:
  file.managed:
    - name: /etc/profile.d/wrapper.sh
    - contents: 'PATH={{ resource_manager_path }}/bin:$PATH'

resource-manager_profile_csh:
  file.managed:
    - name: /etc/profile.d/wrapper.csh
    - contents: 'PATH={{ resource_manager_path }}/bin:$PATH'

{% for exec in execs %}

resource-manager_{{ exec }}:
  file.symlink:
    - name: {{ resource_manager_path }}/bin/{{ exec }}
    - target: {{ resource_manager_path }}/bin/yarn-common-wrapper.sh
    - mode: 755

{% endfor %}
