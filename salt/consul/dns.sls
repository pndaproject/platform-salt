{% set domain_name = pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}

consul_dns-add-nameserver:
  file.prepend:
    - name: /etc/resolv.conf
    - text: |
{%- for ip in salt['pnda.dns_nameserver_ips']() %}
        nameserver {{ ip }}
{%- endfor %}

{% if salt['cmd.run']('grep -i -w ^search[[:space:]].*" ~ domain_name ~ ".*" ~ " /etc/resolv.conf') %}
{% elif salt['cmd.run']('grep -i -w ^search[[:space:]].* /etc/resolv.conf') %}
consul_dns-replace-domain:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: '^search(.*)'
    - repl: 'search {{ domain_name }} \1'
{% else %}
consul_dns-append-domain:
  file.append:
    - name: /etc/resolv.conf
    - text: 'search {{ domain_name }}'
    - ignore_whitespace: False
{% endif %}

{% for cfg_file in salt['cmd.shell']('ls -1 /etc/sysconfig/network-scripts/ifcfg-*').split('\n') %}
consul_turn-off-peer-dns-{{ cfg_file }}:
  file.append:
    - name: {{ cfg_file }}
    - text: PEERDNS=no
{% endfor %}

consul_prevent-modify-resolv-conf:
  cmd.run:
    - name: chattr +i /etc/resolv.conf
