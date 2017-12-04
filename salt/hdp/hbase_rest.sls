{% set rest_port = pillar['hdp']['hbase-rest']['port'] %}
{% set info_port = pillar['hdp']['hbase-rest']['info-port'] %}

{% if grains['os'] == 'Ubuntu' %}
/etc/init/hbase-rest.conf:
  file.managed:
    - source: salt://hdp/templates/hbase-daemon.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
/usr/lib/systemd/system/hbase-rest.service:
  file.managed:
    - source: salt://hdp/templates/hbase-daemon.service.tpl
{% endif %}
    - mode: 644
    - template: jinja
    - context:
      daemon_service: 'rest'
      daemon_port: {{ rest_port }}
      info_port: {{ info_port }}

{% if grains['os'] in ('RedHat', 'CentOS') %}
hdp-systemctl_reload_hbase_rest:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable hbase-rest
{% endif %}

hdp-start_hbase_rest:
  cmd.run:
    - name: 'service hbase-rest stop || echo already stopped; service hbase-rest start'
