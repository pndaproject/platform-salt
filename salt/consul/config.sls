{%- from 'consul/map.jinja' import consul with context -%}

{%- set internal_ip = salt['network.interface_ip'](pillar["mine_functions"]["network.ip_addrs"][0]) -%}
{% do consul.config.update({'bind_addr': internal_ip}) %}
{% do consul.config.update({'client_addr': internal_ip}) %}

{%- if 'consul_server' in salt['grains.get']('roles', []) -%}
{% do consul.config.update({'server': true}) %}
{%- set nb_consul = salt['pnda.dns_nameserver_ips']()|length -%}
{% do consul.config.update({'bootstrap_expect': nb_consul}) %}

{%- else -%}
{%- for ip in salt['pnda.dns_nameserver_ips']() -%}
{%- do consul.config.retry_join.append(ip) -%}
{%- endfor -%}
{% endif %}

consul-config:
  file.serialize:
    - name: /etc/consul.d/config.json
    - formatter: json
    - dataset: {{ consul.config }}
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - mode: 0640
    - require:
      - user: consul-user
    {%- if consul.service %}
    - watch_in:
       - service: consul
    {%- endif %}

{% for script in consul.scripts %}
consul-script-install-{{ loop.index }}:
  file.managed:
    - source: {{ script.source }}
    - name: {{ script.name }}
    - template: jinja
    - context: {{ script.get('context', {}) | yaml }}
    - user: {{ consul.user }}
    - group: {{ consul.group }}
    - mode: 0755
{% endfor %}

