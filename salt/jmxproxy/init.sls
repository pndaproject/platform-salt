{% set jmxproxy_version = salt['pillar.get']('jmxproxy:release_version', '') %}
{% set jmxproxy_hash = salt['pillar.get']('jmxproxy:release_hash', '') %}
{% set jmxproxy_jar = 'jmxproxy-' + jmxproxy_version + '.jar' %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://github.com/mk23/jmxproxy/releases/download/') %}
{% set jmxproxy_url = extra_mirror +  'jmxproxy.' +  jmxproxy_version + '/'+ jmxproxy_jar %}

{% set install_dir = pillar['pnda']['homedir'] %}


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

{% if grains['os'] == 'Ubuntu' %}
jmxproxy-upstart_script:
  file.managed:
    - name: /etc/init/jmxproxy.conf
    - source: salt://{{ sls }}/templates/jmxproxy.conf.tpl
    - mode: 755
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
{% elif grains['os'] == 'RedHat' %}
jmxproxy-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/jmxproxy.service
    - source: salt://{{ sls }}/templates/jmxproxy.service.tpl
    - mode: 755
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
{% endif %}

jmxproxy-start_service:
  service.running:
    - name: jmxproxy
    - enable: true
    - watch:
      - file: jmxproxy-configuration_file
{% if grains['os'] == 'Ubuntu' %}
      - file: jmxproxy-upstart_script
{% elif grains['os'] == 'RedHat' %}
      - file: jmxproxy-systemd
{% endif %}
      - file: jmxproxy-link
