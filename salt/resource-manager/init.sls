{% set resource_manager_dir = pillar['pnda']['homedir'] + "/spark-wrapper" %}
{% set map_file = resource_manager_dir + "/policies/map.txt" %}

resource-manager_user-group-policy_install:
  file.managed:
    - name: {{ resource_manager_dir }}/policies/spark-user-group-policy.sh
    - source: salt://resource-manager/templates/spark-user-group-policy.sh
    - template: jinja
    - defaults:
      map_file: {{ map_file }}
    - mode: 755
    - makedirs: True
    - dir_mode: 755

resource-manager_no_policy_install:
  file.managed:
    - name: {{ resource_manager_dir }}/policies/spark-no-policy.sh
    - source: salt://resource-manager/files/spark-no-policy.sh
    - mode: 755

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

resource-manager_pyspark:
  file.symlink:
    - name: {{ resource_manager_dir }}/pyspark
    - target: {{ resource_manager_dir }}/spark-common-wrapper.sh
    - mode: 755

resource-manager_spark_submit_move:
  file.rename:
    - name: /opt/pnda/spark/spark-submit
    - source: /usr/bin/spark-submit
    - makedirs: True
    - unless: 
      - test -L /usr/bin/spark-submit

resource-manager_spark_shell_move:
  file.rename:
    - name: /opt/pnda/spark/spark-shell
    - source: /usr/bin/spark-shell
    - makedirs: True
    - unless: 
      - test -L /usr/bin/spark-shell

resource-manager_pyspark_move:
  file.rename:
    - name: /opt/pnda/spark/pyspark
    - source: /usr/bin/pyspark
    - makedirs: True
    - unless: 
      - test -L /usr/bin/pyspark

resource-manager_spark_script_move:
  file.rename:
    - name: /opt/pnda/spark/spark-script-wrapper.sh
    - source: /usr/bin/spark-script-wrapper.sh
    - makedirs: True
    - onlyif: 
      - test -x /usr/bin/spark-script-wrapper.sh

resource-manager_spark_submit_orig:
  alternatives.install:
    - name: spark-submit
    - link: /usr/bin/spark-submit
    - path: /opt/pnda/spark/spark-submit
    - priority: 10
    - onlyif:
      - test -x /opt/pnda/spark/spark-submit

resource-manager_spark_shell_orig:
  alternatives.install:
    - name: spark-shell
    - link: /usr/bin/spark-shell
    - path: /opt/pnda/spark/spark-shell
    - priority: 10
    - onlyif:
      - test -x /opt/pnda/spark/spark-shell

resource-manager_pyspark_orig:
  alternatives.install:
    - name: pyspark
    - link: /usr/bin/pyspark
    - path: /opt/pnda/spark/pyspark
    - priority: 10
    - onlyif:
      - test -x /opt/pnda/spark/pyspark

resource-manager_spark_submit_wrapper:
  alternatives.install:
    - name: spark-submit
    - link: /usr/bin/spark-submit
    - path: {{ resource_manager_dir }}/spark-submit
    - priority: 100

resource-manager_spark_shell_wrapper:
  alternatives.install:
    - name: spark-shell
    - link: /usr/bin/spark-shell
    - path: {{ resource_manager_dir }}/spark-shell
    - priority: 100

resource-manager_pyspark_wrapper:
  alternatives.install:
    - name: pyspark
    - link: /usr/bin/pyspark
    - path: {{ resource_manager_dir }}/pyspark
    - priority: 100


