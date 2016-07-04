# In order to work, the salt mine have to be configured to get the
# network_ip_addrs function.

# example:
# mine_functions:
#   network.ip_addrs:
#     - eth0
# mine_interval: 2

{%- set pnda_cluster = salt['pnda.cluster_name']() %}
{%- set addrs = salt['mine.get']('G@pnda_cluster:' + pnda_cluster, 'network.ip_addrs', expr_form='compound') %}

{%- if addrs is defined %}

{%- for name, addrlist in addrs.items() %}
{{ name }}-host-entry:
  host.present:
    - ip: {{ addrlist|first() }}
    - names:
      - {{ name }}
{% endfor %}

{% endif %}

# Remove the 127.0.1.1 entry as it can prevent Cloudera from installing
hostsfile-comment-127.0.1.1-entry:
  file.replace:
    - name: '/etc/hosts'
    - pattern: '^(127.0.1.1.*)$'
    - repl: '#\1'
