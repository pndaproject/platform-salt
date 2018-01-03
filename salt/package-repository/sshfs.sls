{% set sshfs_fs_location_path = salt['pillar.get']('package_repository:fs_location_path', '/opt/pnda/packages') %}
{% set pr_sshfs_identity_file = salt['pillar.get']('package_repository:sshfs_key', 'pr_key') %}
{% set pr_sshfs_user = salt['pillar.get']('package_repository:sshfs_user')%}
{% set pr_sshfs_host = salt['pillar.get']('package_repository:sshfs_host', '127.0.0.1')%}
{% set pr_sshfs_path = salt['pillar.get']('package_repository:sshfs_path', '/mnt/packages')%}
{% set pr_sshfs_device = pr_sshfs_user+'@'+pr_sshfs_host+':'+pr_sshfs_path %}
{% set os_user = pillar['os_user'] %}

sshfs-install:
  pkg.installed:
    - name: {{ pillar['sshfs']['package-name'] }}
    - version: {{ pillar['sshfs']['version'] }}
    - ignore_epoch: True

sshfs-create_directory:
  file.directory:
    - name: {{ sshfs_fs_location_path }}
    - user: {{ os_user }}
    - group: {{ os_user }}
    - mode: 755
    - makedirs: True

ssfhs-copy-key:
  file.managed:
    - name: /opt/pnda/{{ pr_sshfs_identity_file }}
    - source: salt://package-repository/files/{{ pr_sshfs_identity_file }}

sshfs-know_hosts:
  ssh_known_hosts:
    - name: {{ pr_sshfs_host }}
    - present
    - user: root
 
sshfs-mount_directory:
  mount.mounted:
    - name: {{ sshfs_fs_location_path }}
    - device: {{ pr_sshfs_device }}
    - opts: IdentityFile=/opt/pnda/{{ pr_sshfs_identity_file }}
    - fstype: fuse.sshfs
    - persist: True
    - mkmnt: True
    - require:
      - file: ssfhs-copy-key
      - ssh_known_hosts: sshfs-know_hosts