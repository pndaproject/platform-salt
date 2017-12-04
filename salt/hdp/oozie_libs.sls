{% set scripts_location = '/tmp/pnda-install/' + sls %}
{% set httpfs_node = salt['pnda.get_hosts_by_role']('HDFS', 'NAMENODE')[0] %}
{% set oozie_node = salt['pnda.get_hosts_by_role']('OOZIE', 'OOZIE_SERVER')[0] %}
{% set pip_index_url = pillar['pip']['index_url'] %}

include:
  - python-pip

hdp-oozie_libs_link_spark_examples:
  cmd.run:
    - name: 'ln -s /usr/hdp/current/spark-client/lib/spark-examples*.jar /usr/hdp/current/spark-client/lib/spark-examples.jar'

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
    - source: salt://hdp/files/oozie_libs.py

hdp-execute_hdp_installation_script:
  cmd.run:
    - name: {{ scripts_location }}/venv/bin/python {{ scripts_location }}/oozie_libs.py {{ httpfs_node }}

hdp-update_oozie_sharelib:
  cmd.run:
    - name: 'sudo -u oozie oozie admin -oozie http://{{ oozie_node }}:11000/oozie -sharelibupdate'

