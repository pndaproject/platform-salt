{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set anaconda_parcel_version = pillar['anaconda']['parcel_version'] %}
{% set anaconda_package = 'Anaconda2-' + anaconda_parcel_version + '-Linux-x86_64.sh' %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
anaconda-deps:
  pkg.installed:
    - name: {{ pillar['bzip2']['package-name'] }}
    - version: {{ pillar['bzip2']['version'] }}
    - ignore_epoch: True

{%- endif %}

anaconda-dir:
  file.directory:
    - name: /opt/pnda/
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
    - name: './Anaconda2-{{ anaconda_parcel_version }}-Linux-x86_64.sh -b -p /opt/pnda/anaconda'
    - unless: test -d /opt/pnda/anaconda

anaconda-conda_cmd_link:
  file.managed:
    - name: /usr/local/bin/conda
    - source: salt://anaconda/templates/conda-cmd.tpl
    - template: jinja
    - mode: 0755
    - defaults:
        anaconda_bin_dir: /opt/pnda/anaconda/bin

