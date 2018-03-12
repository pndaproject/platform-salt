{%- from 'consul/map.jinja' import consul with context -%}
{% set domain_name = pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
{% set resolv_conf = '/etc/resolv.conf' %}
{% else %}
{% set resolv_conf = '/etc/resolvconf/resolv.conf.d/base' %}
{% endif %}

consul_dns-add-nameserver:
  file.prepend:
    - name: {{ resolv_conf }}
    - text: |
{%- for ip in salt['pnda.kafka_zookeepers_ips']() %}
        nameserver {{ ip }}
{%- endfor %}
        domain {{ domain_name }}

consul_dns-add-domain:
  file.replace:
    - name: {{ resolv_conf }}
    - pattern: 'search(.*)'
    - repl: 'search\1 {{consul.config.domain}}'

{% if grains['os'] in ('RedHat', 'CentOS') %}
{% for cfg_file in salt['cmd.shell']('ls -1 /etc/sysconfig/network-scripts/ifcfg-*').split('\n') %}
consul_turn-off-peer-dns-{{ cfg_file }}:
  file.append:
    - name: {{ cfg_file }}
    - text: PEERDNS=no
{% endfor %}

consul_prevent-modify-resolv-conf:
  cmd.run:
    - name: chattr +i {{ resolv_conf }}

consul_install-at:
  pkg.installed:
    - name: {{ pillar['at']['package-name'] }}
    - version: {{ pillar['at']['version'] }}
    - ignore_epoch: True

consul_start-atd:
  service.running:
    - name: atd
{% else %}
consul_refresh-resolv-conf:
  cmd.run:
    - name: resolvconf -u
{% endif %}

consul_schedule-minion-restart:
  cmd.run:
    - name: 'echo "sleep 30 ; service salt-minion restart" | at now'
