{% set jmxproxy_version = salt['pillar.get']('jmxproxy:release_version', '') %}
{% set jmxproxy_hash = salt['pillar.get']('jmxproxy:release_hash', '') %}
{% set jmxproxy_jar = 'jmxproxy-' + jmxproxy_version + '.jar' %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set jmxproxy_url = mirror_location + jmxproxy_jar %}

{% set install_dir = pillar['pnda']['homedir'] + '/jmxproxy' %}


jmxproxy-create_release_dir:
  file.directory:
    - name: {{ install_dir }}
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

jmxproxy-create_release_dir_etc:
  file.directory:
    - name: {{ install_dir }}/etc
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

jmx-proxy-dl-and-extract:
  file.managed:
    - name: {{ install_dir }}/{{ jmxproxy_jar }}
    - source: {{ jmxproxy_url }}
    - source_hash: {{ jmxproxy_hash }}

jmxproxy-link:
  file.symlink:
    - name: {{ install_dir }}/jmxproxy.jar
    - target: {{ install_dir }}/{{ jmxproxy_jar }}

jmxproxy-configuration_file:
  file.managed:
    - name: {{ install_dir }}/etc/jmxproxy.yaml
    - source: salt://{{ sls }}/files/jmxproxy.yaml

jmxproxy-service_script:
  file.managed:
    - name: /usr/lib/systemd/system/jmxproxy.service
    - source: salt://{{ sls }}/templates/jmxproxy.service.tpl
    - mode: 755
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

jmxproxy-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable jmxproxy

jmxproxy-start_service:
  cmd.run:
    - name: 'service jmxproxy stop || echo already stopped; service jmxproxy start'
