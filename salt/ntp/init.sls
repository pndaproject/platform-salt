{% set ntp_servers = salt['pillar.get']('ntp:servers', []) %}
{% set timezone = salt['pillar.get']('ntp:timezone', 'UTC') %}

ntp-set_timezone:
  timezone.system:
    - name: {{ timezone }}

ntp-install_ntp_package:
  pkg.installed:
    - name: {{ pillar['ntp']['package-name'] }}
    - version: {{ pillar['ntp']['version'] }}
    - ignore_epoch: True

ntp-install_conf:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://ntp/templates/ntp.conf.tpl
    - template: jinja
    - context:
      ntp_servers: {{ ntp_servers }}

ntp-start_service:
  cmd.run:
    {% if grains['os'] in ('RedHat', 'CentOS') %}
    - name: 'service ntpd stop || echo already stopped; service ntpd start'
    {% elif grains['os'] == 'Ubuntu' %}
    - name: 'service ntp stop || echo already stopped; service ntp start'
    {% endif %}
