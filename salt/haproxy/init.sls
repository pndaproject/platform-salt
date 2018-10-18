{% set pnda_domain = pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set grafana_server_node = salt['pnda.get_hosts_for_role']('grafana')[0] + '.' +pillar['consul']['node'] + '.' + pnda_domain %}
{% set jupyter_server_node = salt['pnda.get_hosts_for_role']('jupyter')[0] + '.' +pillar['consul']['node'] + '.' + pnda_domain %}
{% set pnda_home_dir = pillar['pnda']['homedir'] %}
{% set haproxy_config_dir = pnda_home_dir+'/haproxy/conf' %}
{% set haproxy_lib_dir = '/var/lib/haproxy' %}
{% set haproxy_version = pillar['haproxy']['release_version'] %}
{% set haproxy_package = 'haproxy-' + haproxy_version + '.tar.gz' %}
{% set package_server = pillar['packages_server']['base_uri'] %}

# create haproxy user group
haproxy-group:
  group.present:
    - name: haproxy

# create haproxy user
haproxy-user:
  user.present:
    - name: haproxy
    - groups:
      - haproxy
    - createhome: False
    - system: True
    - require:
      - group: haproxy-group

haproxy-install-openssl:
  pkg.installed:
    - name: openssl-libs

# download haproxy binary from mirror and extract
haproxy-install:
  archive.extracted:
    - name: {{ pnda_home_dir }}
    - source: {{ package_server }}/{{ haproxy_package }}
    - source_hash: {{ package_server }}/{{ haproxy_package }}.sha512.txt
    - archive_format: tar
    - if_missing: {{ pnda_home_dir }}/haproxy-{{ haproxy_version }}

# create soft link to haproxy dir
haproxy-create_soft_link:
  file.symlink:
    - target: {{ pnda_home_dir }}/haproxy-{{ haproxy_version}} 
    - name: {{ pnda_home_dir }}/haproxy

# create soft link to haproxy binary
haproxy-create_binary_soft_link:
  file.symlink:
    - target: {{ pnda_home_dir }}/haproxy/haproxy
    - name: /usr/sbin/haproxy

# create haproxy configuration directory
haproxy-create_conf_dir:
  file.directory:
    - name: '{{ haproxy_config_dir }}'

# create haproxy library directory
haproxy-create_lib_dir:
  file.directory:
    - name: '{{ haproxy_lib_dir }}'

# add haproxy statistics file
haproxy-create_empty_stats_file:
  cmd.run:
    - name: 'touch {{ haproxy_lib_dir }}/stats'

{% set bind_options = '' %}
{% if pillar.haproxy is defined and pillar.haproxy.cert is defined and pillar.haproxy.key is defined and pillar.CA is defined and pillar.CA.cert is defined %}
{% set haproxy_tls_concat = haproxy_config_dir + '/haproxy.chain.pem' %}
haproxy-create_tls_join:
  file.managed:
    - name: {{ haproxy_tls_concat }}
    - user: haproxy
    - group: haproxy
    - mode: 600
    - contents: |
        {{ pillar['haproxy']['cert']|indent(8) }}
        {{ pillar['haproxy']['key']|indent(8) }}
        {{ pillar['CA']['cert']|indent(8) }}
{% set bind_options = 'ssl crt ' + haproxy_tls_concat %}
{% endif %}

# create configuration using template
haproxy-create_config:
  file.managed:
    - source: salt://haproxy/templates/haproxy.cfg.tpl
    - name: {{ haproxy_config_dir }}/haproxy.cfg
    - template: jinja
    - defaults:
        grafana_server_node: {{ grafana_server_node }}
        jupyter_server_node: {{ jupyter_server_node }}
        pnda_domain: {{ pnda_domain }}
        bind_options: {{ bind_options }}

# create softlink to haproxy manual
haproxy-install_man:
  file.symlink:
    - target: {{ pnda_home_dir }}/haproxy/doc/haproxy.1
    - name: /usr/share/man/man1/haproxy.1

# set up haproxy systemd service
haproxy-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/haproxy.service
    - source: salt://haproxy/templates/haproxy.service.tpl
    - mode: 644
    - template: jinja
    - context:
      haproxy_config_dir: {{ haproxy_config_dir }}

# reload systemd
haproxy-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable haproxy

# start haproxy service
haproxy-start_service:
  cmd.run:
    - name: 'service haproxy stop || echo already stopped; service haproxy start'
