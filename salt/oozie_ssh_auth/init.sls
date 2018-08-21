{% set oozie_dir = salt['cmd.run']('getent passwd oozie | cut -d: -f6') %}
{% set oozie_ssh_dir = oozie_dir+"/.ssh" %}

{% set dm_id = salt['pnda.get_hosts_for_role']('deployment_manager')[0] %}

oozie-ssh-create-dir:
  file.directory:
    - name: {{ oozie_ssh_dir }}
    - makedirs: True
    - user: oozie
    - group: hadoop
    - mode: 700

oozie-ssh-install-key:
  file.managed:
    - name: {{ oozie_ssh_dir }}/id_rsa
    - source: salt://{{ dm_id }}/keys/dm.pem
    - user: oozie
    - group: hadoop
    - mode: 600
