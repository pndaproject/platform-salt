{% set rest_port = pillar['hbase-rest']['port'] %}
{% set info_port = pillar['hbase-rest']['info-port'] %}

/usr/lib/systemd/system/hbase-rest.service:
  file.managed:
    - source: salt://hdp/templates/hbase-daemon.service.tpl
    - mode: 644
    - template: jinja
    - context:
      daemon_service: 'rest'
      daemon_port: {{ rest_port }}
      info_port: {{ info_port }}

hdp-systemctl_reload_hbase_rest:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable hbase-rest

hdp-start_hbase_rest:
  cmd.run:
    - name: 'service hbase-rest stop || echo already stopped; service hbase-rest start'
