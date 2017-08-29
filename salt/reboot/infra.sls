{% if grains['os'] in ('RedHat', 'CentOS') %}
reboot-install_deps:
  pkg.installed:
    - name: {{ pillar['at']['package-name'] }}
    - version: {{ pillar['at']['version'] }}
    - ignore_epoch: True

reboot-start_atd:
  service.running:
    - name: atd
{% endif %}

reboot-schedule_reboot:
  cmd.run:
    - name: 'echo shutdown -r now | at now + 2 minute'
{% if grains['os'] == 'Ubuntu' %}
    - onlyif:
      - ls /var/run/reboot-required
{% endif %}
