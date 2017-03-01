cdh-clean-sources-list:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: rm -rf /etc/apt/sources.list.d/cloudera-manager.list
{% elif grains['os'] == 'RedHat' %}
    - name: rm -rf /etc/yum.repos.d/*cloudera*
{% endif %}
