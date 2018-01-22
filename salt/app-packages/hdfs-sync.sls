{% set pnda_home = pillar['pnda']['homedir'] %}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set app_packages_hdfs_path = pillar['pnda']['app_packages']['app_packages_hdfs_path'] %}
{% set app_packages_mirror_path = pillar['pnda_mirror']['app_packages_path'] %}
{% set app_packages_fs_path = pnda_home + "/apps-packages" %}
{% set mirror_url = pnda_mirror + app_packages_mirror_path %}

app-packages-create-directory:
  file.directory:
    - name: {{ app_packages_fs_path }}
    - mode: 755
    - makedirs: True

app-packages-instantiate-package-list:
  file.managed:
    - name: {{ app_packages_fs_path }}/app-packages-hdfs.txt
    - source: salt://app-packages/files/app-packages-hdfs.txt
    - template: jinja

app-packages-sync-hdfs:
  cmd.script:
    - name: salt://app-packages/templates/sync.sh.tpl
    - template: jinja
    - context:
        app_packages_hdfs_path : {{ app_packages_hdfs_path }}
        mirror_url: {{ mirror_url }}
        app_packages_fs_path: {{ app_packages_fs_path }}/app-packages-hdfs.txt
    - cwd: {{ app_packages_fs_path }}
