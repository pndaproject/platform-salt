gobblin-require_gobblin_service_script:
  file.exists:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/gobblin.conf
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /usr/lib/systemd/system/gobblin.service
{%- endif %}

{% if grains['os'] == 'Ubuntu' %}
gobblin-sbin_ubuntu_start:
  cmd.run:
    - name: /sbin/start gobblin
{% elif grains['os'] == 'RedHat' %}
gobblin-systemctl_redhat_start:
  cmd.run:
    - name: /bin/systemctl start gobblin
{%- endif %}
    - require:
      - file: gobblin-require_gobblin_service_script 

gobblin-add_gobblin_crontab_entry:
  cron.present:
    - identifier: GOBBLIN
{% if grains['os'] == 'Ubuntu' %}
    - name: /sbin/start gobblin
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /bin/systemctl start gobblin
{%- endif %}
    - user: root
    - minute: 0,30
    - require:
      - file: gobblin-require_gobblin_service_script
