{% set ntp_servers = salt['pillar.get']('ntp:servers', []) %}

ntp-install_ntp_package:
  pkg.installed:
    - name: ntp

ntp-install_conf:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://ntp/templates/ntp.conf.tpl
    - template: jinja
    - context:
      ntp_servers: {{ ntp_servers }}

ntp-service-running:
  service.running:
    - name: ntp
    - enable: true
    - watch:
      - file: ntp-install_conf
