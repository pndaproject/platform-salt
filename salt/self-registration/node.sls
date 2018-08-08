include:
  - self-registration

self-registration-node-script:
  file.managed:
    - name: /opt/pnda/utils/register-node.sh
    - source: salt://self-registration/files/register-node.sh.tpl
    - mode: 755
    - template: jinja
    - context:
      consul_datacenter: {{ pillar['consul']['data_center'] }}
    - require:
      - file: self-registration-dir

self-registration-node-register:
  cmd.run:
    - name: '/opt/pnda/utils/register-node.sh'