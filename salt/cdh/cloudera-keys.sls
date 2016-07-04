{% set cluster = salt['pnda.cluster_name']() %}

cloudera-key-generate-cloudera-keys:
  cmd.run:
    - name: 'ssh-keygen -b 2048 -t rsa -f /tmp/cloudera.pem -q -N ""'
    - unless: test -f /tmp/cloudera.pem

cloudera-key-upload-to-master:
  module.run:
    - name: cp.push
    - path: /tmp/cloudera.pem.pub
    - onchanges:
      - cmd: cloudera-key-generate-cloudera-keys
