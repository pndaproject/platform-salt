{% set resource_manager_dir = pillar['pnda']['homedir'] + "/spark-wrapper" %}
{% set map_file = resource_manager_dir + "/policies/map.txt" %}

resource-manager_group_script_install:
  file.managed:
    - name: {{ resource_manager_dir }}/policies/spark-user-group-policy.sh
    - source: salt://resource-manager/templates/spark-user-group-policy.sh
    - template: jinja
    - defaults:
      map_file: {{ map_file }}
    - mode: 755
    - makedirs: True
    - dir_mode: 755

resource-manager_group_map_install:
  file.managed:
    - name: {{ map_file }}
    - source: salt://resource-manager/templates/map.txt
    - mode: 755

resource-manager_policy_selection:
  file.symlink:
    - name: {{ resource_manager_dir }}/spark-policy.sh
    - target: {{ resource_manager_dir }}/policies/spark-user-group-policy.sh
    - mode: 755

resource-manager_spark_common_wrapper:
  file.managed:
    - name: {{ resource_manager_dir }}/spark-common-wrapper.sh
    - source: salt://resource-manager/templates/spark-common-wrapper.sh
    - template: jinja
    - defaults:
      resource_manager_dir: {{ resource_manager_dir }}
    - mode: 755

resource-manager_spark_submit:
  file.symlink:
    - name: {{ resource_manager_dir }}/spark-submit
    - target: {{ resource_manager_dir }}/spark-common-wrapper.sh
    - mode: 755

resource-manager_spark_shell:
  file.symlink:
    - name: {{ resource_manager_dir }}/spark-shell
    - target: {{ resource_manager_dir }}/spark-common-wrapper.sh
    - mode: 755
