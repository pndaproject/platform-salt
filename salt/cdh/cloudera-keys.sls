{% set cluster = salt['pnda.cluster_name']() %}

{% set ssh_prv_key = '/tmp/cloudera.pem' %}

cloudera-key-generate-cloudera-keys:
  cmd.run:
    - name: 'ssh-keygen -b 2048 -t rsa -f {{ ssh_prv_key }} -q -N ""'
    - unless: test -f {{ ssh_prv_key }}

cloudera-key-upload-to-master:
  module.run:
    - name: cp.push
    - path: {{ ssh_prv_key }}.pub
    - upload_path: /keys/cloudera.pem.pub
    - onchanges:
      - cmd: cloudera-key-generate-cloudera-keys
