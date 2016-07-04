{% set deployment_manager_version = salt['pillar.get']('deployment_manager:release_version', '1.0.0') %}
{% set deployment_manager_directory_name = 'deployment-manager-' + deployment_manager_version %}
{% set cluster = salt['pnda.cluster_name']() %}
{% set install_dir = '/opt/pnda' %}
{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}

cdh-install_pub_key:
  module.run:
    - name: cp.get_file
    - path: 'salt://{{ cluster }}-cdh-edge{{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem.pub'
    - dest: /tmp/pubkey

cdh-install_key:
  cmd.run:
    - name: 'cat /tmp/pubkey >> /home/{{ os_user }}/.ssh/authorized_keys'


