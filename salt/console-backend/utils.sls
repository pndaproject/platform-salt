{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_utils_version = pillar['console_backend_utils']['release_version'] %}
{% set backend_utils_package = 'console-backend-utils-' + backend_utils_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set utils_dir = install_dir + '/console-backend-utils' %}

include:
  - nodejs

console-backend-utils-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ backend_utils_package }}
    - source_hash: {{ packages_server }}/{{ backend_utils_package }}.sha512.txt
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ install_dir }}/console-backend-utils-{{ backend_utils_version }}

console-backend-symlink_utils_dir:
  file.symlink:
    - name: {{ utils_dir }}
    - target: {{ install_dir }}/console-backend-utils-{{ backend_utils_version }}

# Install npm dependencies for utils
console-backend-install_utils_dependencies:
  cmd.run:
    - cwd: {{ install_dir }}/console-backend-utils
    - name: npm rebuild > /dev/null
    - require:
      - archive: nodejs-dl_and_extract_node