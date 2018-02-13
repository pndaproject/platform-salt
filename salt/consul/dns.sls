{%- from 'consul/map.jinja' import consul with context -%}

consul_dns-add-nameserver:
  file.prepend:
    - name: /etc/resolv.conf
    - text: |
{%- for ip in salt['pnda.kafka_zookeepers_ips']() %}
        nameserver {{ ip }}
{%- endfor %}

consul_dns-add-domain:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: 'search(.*)'
    - repl: 'search\1 {{consul.config.domain}}'