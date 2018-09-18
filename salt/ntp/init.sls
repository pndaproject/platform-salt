{% set ntp_servers = salt['pillar.get']('ntp:servers', []) %}
{% set timezone = salt['pillar.get']('ntp:timezone', 'UTC') %}

ntp-set_timezone:
  timezone.system:
    - name: {{ timezone }}

ntp-install_ntp_package:
  pkg.installed:
    - name: chrony
    - ignore_epoch: True

ntp-install_conf:
  file.managed:
    - name: /etc/chrony.conf
    - source: salt://ntp/templates/chrony.conf.tpl
    - template: jinja
    - context:
      ntp_servers: {{ ntp_servers }}

ntp-enable_chronyd:
  service.running:
    - name: chronyd
    - enable: True
    - watch:
      - pkg: ntp-install_ntp_package
      - file: ntp-install_conf
