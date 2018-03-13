{% set domain_name = pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% if grains['os'] in ('RedHat', 'CentOS') %}

consul_dns-add-nameserver:
  file.prepend:
    - name: /etc/resolv.conf
    - text: |
{%- for ip in salt['pnda.dns_nameserver_ips']() %}
        nameserver {{ ip }}
{%- endfor %}

consul_dns-add-domain:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: 'search(.*)'
    - repl: 'search\1 {{ domain_name }}'

{% for cfg_file in salt['cmd.shell']('ls -1 /etc/sysconfig/network-scripts/ifcfg-*').split('\n') %}
consul_turn-off-peer-dns-{{ cfg_file }}:
  file.append:
    - name: {{ cfg_file }}
    - text: PEERDNS=no
{% endfor %}

consul_prevent-modify-resolv-conf:
  cmd.run:
    - name: chattr +i /etc/resolv.conf

{% else %}

consul_dns-add-nameserver:
  file.append:
    - name: /etc/resolvconf/resolv.conf.d/head
    - text: |
{%- for ip in salt['pnda.dns_nameserver_ips']() %}
        nameserver {{ ip }}
{%- endfor %}

consul_dns-add-domain:
  file.append:
    - name: /etc/resolvconf/resolv.conf.d/base
    - text: 'search {{ domain_name }}'

consul_refresh-resolv-conf:
  cmd.run:
    - name: resolvconf -u

{% endif %}