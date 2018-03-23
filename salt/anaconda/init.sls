{% set install_dir = pillar['pnda']['homedir'] %}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set anaconda_bundle_version = pillar['anaconda']['bundle_version'] %}
{% set anaconda_package = 'Anaconda2-' + anaconda_bundle_version + '-Linux-x86_64.sh' %}
{% set anaconda_link = install_dir + '/anaconda' %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
anaconda-deps:
  pkg.installed:
    - name: {{ pillar['bzip2']['package-name'] }}
    - version: {{ pillar['bzip2']['version'] }}
    - ignore_epoch: True

{%- endif %}

anaconda-dir:
  file.directory:
    - name: {{ install_dir }}
    - makedirs: True

anaconda-dl:
  file.managed:
    - name: /tmp/{{ anaconda_package }}
    - mode: 755
    - source: {{ mirror_location }}/{{ anaconda_package }}
    - source_hash: {{ mirror_location }}/{{ anaconda_package }}.sha512.txt

anaconda-setup:
  cmd.run:
    - cwd: /tmp
    - name: './Anaconda2-{{ anaconda_bundle_version }}-Linux-x86_64.sh -b -p {{ install_dir }}/anaconda-{{ anaconda_bundle_version }}'
    - unless: test -d {{ install_dir }}/anaconda-{{ anaconda_bundle_version }}

anaconda-create_directory_link:
  file.symlink:
    - name: {{ anaconda_link }}
    - target: {{ install_dir }}/anaconda-{{ anaconda_bundle_version }}
    - force: True
    - backupname: {{ anaconda_link }}.backup

anaconda-conda_cmd_link:
  file.managed:
    - name: /usr/local/bin/conda
    - source: salt://anaconda/templates/conda-cmd.tpl
    - template: jinja
    - mode: 0755
    - defaults:
        anaconda_bin_dir: {{ anaconda_link }}/bin
