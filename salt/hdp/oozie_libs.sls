{% set scripts_location = '/tmp/pnda-install/' + sls %}
{% set httpfs_node = salt['pnda.get_hosts_by_role']('HDFS', 'NAMENODE')[0] %}
{% set oozie_node = salt['pnda.get_hosts_by_role']('OOZIE', 'OOZIE_SERVER')[0] %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set oozie_spark_version = salt['pillar.get']('hdp:oozie_spark_version', '1') %}

include:
  - python-pip

hdp-oozie_libs_create_virtualenv:
  virtualenv.managed:
    - name: {{ scripts_location }}/venv
    - requirements: salt://hdp/files/requirements-hdp_setup.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

hdp-oozie_libs_script:
  file.managed:
    - name: {{ scripts_location}}/oozie_libs.py
    - source: salt://hdp/templates/oozie_libs.py.tpl
    - template: jinja
    - defaults:
        spark_examples_jar: {{ spark_examples_jar }}

hdp-execute_hdp_installation_script:
  cmd.run:
    - name: {{ scripts_location }}/venv/bin/python {{ scripts_location }}/oozie_libs.py {{ httpfs_node }}

hdp-oozie_sharelib_spark:
  cmd.script:
    - name: salt://hdp/files/sharelib-spark{{ oozie_spark_version }}.sh
    - args: {{ oozie_node }}

