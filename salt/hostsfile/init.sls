{% set hostname = grains['host'] %}
{% set domain_name = '.' + pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}

hostsfile-fqdn-entry:
  host.present:
    - ip: {{ grains['ipv4'][0] }}
    - names:
      - {{ hostname }}{{ domain_name }}

hostsfile-hostname-entry:
  host.present:
    - ip: {{ grains['ipv4'][0] }}
    - names:
      - {{ hostname }}

# Remove the 127.0.1.1 entry as it can prevent Cloudera from installing
hostsfile-comment-127.0.1.1-entry:
  file.replace:
    - name: '/etc/hosts'
    - pattern: '^(127.0.1.1.*)$'
    - repl: '#\1'
