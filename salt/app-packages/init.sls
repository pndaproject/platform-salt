{% set pnda_home = pillar['pnda']['homedir'] %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set app_packages_hdfs_path = pillar['pnda']['app_packages']['app_packages_hdfs_path'] %}

include:
  - python-pip

app-packages-create-venv:
  virtualenv.managed:
    - name: {{ pnda_home }}/app-packages
    - python: python2
    - requirements: salt://app-packages/files/app-packages-requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

app-packages-initialize-hdfs:
  cmd.run:
    - name: 'sudo -u hdfs hdfs dfs -mkdir -p {{ app_packages_hdfs_path }}'
