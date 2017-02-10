reboot-schedule_reboot:
  cmd.run:
    - name: 'echo shutdown -r now | at now + 2 minute'
{% if grains['os'] == 'Ubuntu' %}
    - onlyif:
      - ls /var/run/reboot-required
{% endif %}
