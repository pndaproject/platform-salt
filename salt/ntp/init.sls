{% set ntp_servers = salt['pillar.get']('ntp:servers', []) %}
{% set timezone = salt['pillar.get']('ntp:timezone', 'UTC') %}
{% set ntp_service = pillar['ntp']['service_name'] %}

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

ntp-ntpdate_sync_on_boot_script:
  file.managed:
    - name: /etc/ntpdate.sh
    - source: salt://ntp/files/ntpdate.sh
    - mode: 0755
    - template: jinja
    - context:
      ntp_service: {{ ntp_service }}
      ntp_servers: {{ ntp_servers }}

{% if grains['os'] in ('RedHat', 'CentOS') %}
ntp-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable {{ ntp_service }}; /bin/systemctl stop chronyd; /bin/systemctl disable chronyd; /bin/systemctl enable ntpdate;
{%- else %}
ntp-ntpdate_sync_on_boot_cmd:
  file.append:
    - name: /etc/rc.local
    - text:
      - "/etc/ntpdate.sh 2>&1 | tee -a /var/log/pnda/ntpdate_sync_on_boot.log"
{%- endif %}

ntp-ntpdate-sync:
  cmd.run:
    - name: '/etc/ntpdate.sh'

