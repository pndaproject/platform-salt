{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set app_version = salt['pillar.get']('hdfs_cleaner:release_version', '1.0.0') %}
{% set app_directory_name = 'hdfs-cleaner-' + app_version %}
{% set app_package = 'hdfs-cleaner-' + app_version + '.tar.gz' %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set archive_container = salt['pillar.get']('pnda.archive_container', 'archive') %}
{% set archive_type = salt['pillar.get']('pnda.archive_type', 'swift') %}
{% set archive_service = salt['pillar.get']('pnda.archive_service', '.pnda') %}

{% set pnda_user  = pillar['pnda']['user'] %}
{% set gobblin_work_dir = '/user/' + pnda_user + '/gobblin/work' %}

{% set install_dir = pillar['pnda']['homedir'] %}

{% set virtual_env_dir = install_dir + "/" + app_directory_name + "/venv" %}

include:
  - python-pip

hdfs-cleaner-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ app_package }}
    - source_hash: {{ packages_server }}/{{ app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/{{ app_directory_name }}

hdfs-cleaner-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: salt://hdfs-cleaner/files/requirements.txt
    - require:
      - pip: python-pip-install_python_pip
      - archive: hdfs-cleaner-dl-and-extract

hdfs-cleaner-create_link:
  file.symlink:
    - name: {{ install_dir }}/hdfs-cleaner
    - target: {{ install_dir }}/{{ app_directory_name }}
    - require:
      - archive: hdfs-cleaner-dl-and-extract

hdfs-cleaner-copy_config:
  file.managed:
    - name: {{ install_dir }}/hdfs-cleaner/properties.json
    - source: salt://hdfs-cleaner/templates/properties.json.tpl
    - template: jinja
    - defaults:
        container: {{ archive_container }}
        repo_path: {{ pnda_cluster }}
        archive_type: '{{ archive_type }}'
        archive_service: '{{ archive_service }}'
        gobblin_work_dir: {{ gobblin_work_dir }}
    - require:
      - file: hdfs-cleaner-create_link

hdfs-cleaner-copy_upstart:
  file.managed:
    - name: /etc/init/hdfs-cleaner.conf
    - source: salt://hdfs-cleaner/templates/hdfs-cleaner.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

hdfs-cleaner-add_crontab_entry:
  cron.present:
    - identifier: HDFS-CLEANER
    - name: /sbin/start hdfs-cleaner
    - user: root
    - hour: '*/4'
    - minute: 0

/data0/tmp/hadoop-hdfs:
  file.directory:
    - user: root
    - mode: 777
    - makedirs: True
