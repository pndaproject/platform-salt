{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set node_version = pillar['nodejs']['version'] %}
{% set node_package = node_version + '.tar.gz' %}
{% set node_url = mirror_location + node_package %}

{% set install_dir = pillar['pnda']['homedir'] %}

nodejs-dl_and_extract_node:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ node_url }}
    - source_hash: {{ node_url }}.sha1.txt
    - archive_format: tar
    - if_missing: {{ install_dir }}/{{ node_version }}

nodejs-create_install_link:
  file.symlink:
    - name: {{ install_dir }}/nodejs
    - target: {{ install_dir }}/{{ node_version }}

nodejs-create_bin_link_node:
  file.symlink:
    - force: True
    - name: /usr/bin/node
    - target: {{ install_dir }}/{{ node_version }}/bin/node

nodejs-create_bin_link_node-gyp:
  file.symlink:
    - force: True
    - name: /usr/bin/node-gyp
    - target: {{ install_dir }}/{{ node_version }}/bin/node-gyp

nodejs-create_bin_link_npm:
  file.symlink:
    - force: True
    - name: /usr/bin/npm
    - target: {{ install_dir }}/{{ node_version }}/bin/npm
