{% if grains['os'] == 'RedHat' %}
reboot-install_deps:
  pkg.installed:
    - pkgs:
      - at

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
