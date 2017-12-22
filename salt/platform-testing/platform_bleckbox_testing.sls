platform-testing-cdh-crontab-cdh_blackbox:
  cron.present:
    - identifier: PLATFORM-TESTING-CDH-BLACKBOX
    - user: root
{% if grains['os'] == 'Ubuntu' %}
    - name: /sbin/start platform-testing-cdh-blackbox
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /bin/systemctl start platform-testing-cdh-blackbox
{% endif %}
