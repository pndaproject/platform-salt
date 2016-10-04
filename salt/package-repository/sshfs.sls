{% set sshfs_fs_location_path = salt['pillar.get']('package_repository:fs_location_path', '/opt/pnda/packages') %}
{% set sshfs_device = salt['pillar.get']('package_repository:device', 'cloud-user@127.0.0.1:/opt/packages') %}
{% set sshfs_identity_file = salt['pillar.get']('package_repository:identity_file', '/opt/pnda/id_rsa') %}

sshfs-install:
  pkg.installed:
    - name: sshfs

sshfs-create_directory:
  file.directory:
    - name: {{ sshfs_fs_location_path }}
    - user: {{ os_user }}
    - group: {{ os_user }}
    - mode: 755
    - makedirs: True

sshfs-know_hosts:
  ssh_known_hosts:
    - name: {{ sshfs_host }}
    - present
    - user: root
 
sshfs-mount_directory:
  mount.mounted:
    - name: {{ sshfs_fs_location_path }}
    - device: {{ sshfs_device }}
    - opts: IdentityFile={{ sshfs_identity_file }}
    - fstype: fuse.sshfs
    - persist: True
    - mkmnt: True