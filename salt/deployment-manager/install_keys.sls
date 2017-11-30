{% set deployment_manager_version = salt['pillar.get']('deployment_manager:release_version', '1.0.0') %}
{% set deployment_manager_directory_name = 'deployment-manager-' + deployment_manager_version %}
{% set cluster = salt['pnda.cluster_name']() %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}

{% set dm_id = salt['mine.get']('G@pnda_cluster:{} and G@roles:deployment_manager'.format(cluster),
                                'network.ip_addrs',
                                expr_form='compound').keys()|first %}

deployment-manager-install_pub_key:
  module.run:
    - name: cp.get_file
    - path: 'salt://{{ dm_id }}/keys/dm.pem.pub'
    - dest: /tmp/pubkey

deployment-manager-install_key:
  cmd.run:
    - name: "cat /tmp/pubkey >> $(getent passwd {{ os_user }} | cut -d: -f6)/.ssh/authorized_keys"


