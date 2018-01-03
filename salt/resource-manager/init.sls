{% set resource_manager_path = pillar['resource_manager']['path'] %}
{% set map_file = resource_manager_path + "policies/map.txt" %}
{% set policy_file_link = resource_manager_path + pillar['resource_manager']['policy_file'] %}
{% set execs = [ 'spark-submit', 'spark-shell', 'pyspark', 'mapred' ] %} 
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

resource-manager_spark_common_wrapper:
  file.managed:
    - name: {{ resource_manager_path }}/spark-common-wrapper.sh
    - source: salt://resource-manager/templates/spark-common-wrapper.sh
    - template: jinja
    - defaults:
        resource_manager_path: {{ resource_manager_path }}
        policy_file_link: {{ policy_file_link }}
    - mode: 755

{% for exec in execs %}

resource-manager_{{ exec }}:
  file.symlink:
    - name: {{ resource_manager_path }}/{{ exec }}
    - target: {{ resource_manager_path }}/spark-common-wrapper.sh
    - mode: 755

resource-manager_{{ exec }}_move:
  file.rename:
    - name: /opt/pnda/rm_spark/{{ exec }}
    - source: /usr/bin/{{ exec }}
    - makedirs: True
    - unless: 
      - test -L /usr/bin/{{ exec }}

resource-manager_{{ exec }}_orig:
  alternatives.install:
    - name: {{ exec }}
    - link: /usr/bin/{{ exec }}
    - path: /opt/pnda/rm_spark/{{ exec }}
    - priority: 10
    - onlyif:
      - test -x /opt/pnda/rm_spark/{{ exec }}

resource-manager_{{ exec }}_wrapper:
  alternatives.install:
    - name: {{ exec }}
    - link: /usr/bin/{{ exec }}
    - path: {{ resource_manager_path }}/{{ exec }}
    - priority: 100

{% endfor %}

resource-manager_spark_script_move:
  file.rename:
    - name: /opt/pnda/rm_spark/spark-script-wrapper.sh
    - source: /usr/bin/spark-script-wrapper.sh
    - makedirs: True
    - onlyif: 
      - test -x /usr/bin/spark-script-wrapper.sh
