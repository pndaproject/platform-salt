{% set pnda_user = pillar['pnda']['user'] %}
{% set pnda_password = pillar['pnda']['password_hash'] %}
{% set pnda_group = pillar['pnda']['group'] %}
{% set pnda_home_directory = pillar['pnda']['homedir'] %}

pnda-install_selinux:
  pkg.installed:
    - pkgs:
      - policycoreutils-python
      - selinux-policy-targeted

{% if salt['cmd.run']('getenforce')|lower != 'disabled' %}
permissive:
  selinux.mode: []
  file.replace:
    - name: '/etc/selinux/config'
    - pattern: '^SELINUX=(?!\s*permissive).*'
    - repl: 'SELINUX=permissive'
    - append_if_not_found: True
    - show_changes: True
{% endif %}

pnda-create_pnda_user:
  user.present:
    - name: {{ pnda_user }}
    - password: {{ pnda_password }}
    - home: {{ pnda_home_directory }}
    - createhome: True

pnda-create_pnda_group:
  group.present:
    - name: {{ pnda_group }}
    - addusers:
      - {{ pnda_user }}

pnda-set_home_dir_perms:
  file.directory:
    - name: {{ pnda_home_directory }}
    - mode: 755
