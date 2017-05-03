{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set node_package = 'node-v6.10.2-linux-x64.tar.gz' %}
{% set node_url = mirror_location + node_package %}

nodejs-dl_and_extract_node:
  archive.extracted:
    - name: /usr/
    - source: {{ node_url }}
    - source_hash: {{ node_url }}.sha1.txt
    - archive_format: tar
    - tar_options: --strip-components=1
    - if_missing: /usr/bin/node
