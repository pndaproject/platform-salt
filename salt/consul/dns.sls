{%- from 'consul/map.jinja' import consul with context -%}
{% set domain_name = pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}

consul_dns-add-nameserver:
  file.prepend:
    - name: /etc/resolv.conf
    - text: |
{%- for ip in salt['pnda.kafka_zookeepers_ips']() %}
        nameserver {{ ip }}
{%- endfor %}
        domain {{ domain_name }}

consul_dns-add-domain:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: 'search(.*)'
    - repl: 'search\1 {{consul.config.domain}}'

{% if grains['os'] == 'RedHat' %}
# Temporary fix to stop this file being reset on RedHat
# There is probably a more appropriate way to do this
# Both ubuntu and redhat need a fix to prevent the changes
# to resolv.conf from being lost.
consul_prevent-modify-resolv-conf:
  cmd.run:
    - name: chattr +i /etc/resolv.conf

consul_install-at:
  pkg.installed:
    - name: {{ pillar['at']['package-name'] }}
    - version: {{ pillar['at']['version'] }}
    - ignore_epoch: True

consul_start-atd:
  service.running:
    - name: atd
{% endif %}

consul_schedule-minion-restart:
  cmd.run:
    - name: 'echo "sleep 30 ; service salt-minion restart" | at now'
