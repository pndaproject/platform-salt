{%- set cm_ver = '5.9.0' -%}
{%- set cm_mirror = salt['pillar.get']('cloudera:cm_mirror', 'https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm') -%}

cloudera-mirror-add_cloudera_manager_repository:
  pkgrepo.managed:
{% if grains['os'] == 'Ubuntu' %}
    - humanname: Cloudera Manager
    - name: deb [arch=amd64] {{ cm_mirror }} trusty-cm{{cm_ver}} contrib
    - dist: trusty-cm{{cm_ver}}
    - key_url: {{ cm_mirror }}/archive.key
    - refresh: True
    - file: /etc/apt/sources.list.d/cloudera.list
{% elif grains['os'] == 'RedHat' %}
    - humanname: Cloudera Manager
    - baseurl: http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5/
    - gpgkey: https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/RPM-GPG-KEY-cloudera
{% endif %}