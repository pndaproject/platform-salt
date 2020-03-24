{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set app_version = salt['pillar.get']('hdfs_cleaner:release_version', '1.0.0') %}
{% set app_directory_name = 'hdfs-cleaner-' + app_version %}
{% set app_package = 'hdfs-cleaner-' + app_version + '.tar.gz' %}
{% set repo_path = salt['pillar.get']('pnda.archive_repo_path') %}
{% set archive_container = salt['pillar.get']('pnda.archive_container', 'archive') %}
{% set archive_type = salt['pillar.get']('pnda.archive_type', 'swift') %}
{% set archive_service = salt['pillar.get']('pnda.archive_service', '.pnda') %}

{% set hadoop_distro = grains['hadoop.distro'] %}
{% set pnda_user  = pillar['pnda']['user'] %}
{% set gobblin_work_dir = '/user/' + pnda_user + '/gobblin/work' %}
{% set flink_job_dir = '/' + pnda_user + '/flink/completed-jobs' %}

{% set install_dir = pillar['pnda']['homedir'] %}

{% set virtual_env_dir = install_dir + "/" + app_directory_name + "/venv" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

{% if grains['hadoop.distro'] == 'HDP' %}
{% set streaming_dirs_to_clean = '"/user/*/.sparkStaging/", "/app-logs/*/logs/", "/spark-history/", "/user/*/.flink/"' %}
{% set general_dirs_to_clean = '"/mr-history/done/"' %}
{% else %}
{% set streaming_dirs_to_clean = '"/user/*/.sparkStaging/", "/tmp/logs/*/logs/", "/user/spark/applicationHistory/", "/user/*/.flink/"' %}
{% set general_dirs_to_clean = '"/user/history/done/"' %}
{% endif %}

include:
  - python-pip

hdfs-cleaner-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ app_package }}
    - source_hash: {{ packages_server }}/{{ app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ install_dir }}/{{ app_directory_name }}

hdfs-cleaner-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: {{ install_dir }}/{{ app_directory_name }}/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
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
        hadoop_distro: {{ hadoop_distro }}
        container: {{ archive_container }}
        repo_path: {{ repo_path }}
        archive_type: '{{ archive_type }}'
        archive_service: '{{ archive_service }}'
        gobblin_work_dir: {{ gobblin_work_dir }}
        flink_job_dir: {{ flink_job_dir }}
        streaming_dirs_to_clean: '{{ streaming_dirs_to_clean }}'
        general_dirs_to_clean: '{{ general_dirs_to_clean }}'
    - require:
      - file: hdfs-cleaner-create_link

hdfs-cleaner-copy_service:
  file.managed:
    - name: /usr/lib/systemd/system/hdfs-cleaner.service
    - source: salt://hdfs-cleaner/templates/hdfs-cleaner.service.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

hdfs-cleaner-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload

hdfs-cleaner-add_crontab_entry:
  cron.present:
    - identifier: HDFS-CLEANER
    - name: /bin/systemctl start hdfs-cleaner
    - user: root
    - hour: '*/4'
    - minute: 0

/mnt/hadoop-tmp:
  file.directory:
    - user: root
    - mode: 777
    - makedirs: True
