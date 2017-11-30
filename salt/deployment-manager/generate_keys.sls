{%- set keys_directory = pillar['deployment_manager']['keys_directory'] -%}

deployment-manager-create_keys_directory:
  file.directory:
    - name: {{ keys_directory }}
    - makedirs: True

deployment-manager-gen_key:
  cmd.run:
    - name: 'ssh-keygen -b 2048 -t rsa -f {{ keys_directory }}/dm.pem -q -N ""'
    - unless: test -f {{ keys_directory }}/dm.pem

deployment-manager-push_key:
  module.run:
    - name: cp.push
    - path: '{{ keys_directory }}/dm.pem.pub'
    - upload_path: '/keys/dm.pem.pub'
    - require:
      - cmd: deployment-manager-gen_key