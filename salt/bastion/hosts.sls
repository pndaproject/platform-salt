{% for id, addr_list in salt['mine.get']('*', 'network.ip_addrs').items() %}
{% if id != grains['id'] %}
{{ id }}-host-entry:
  host.present:
    - ip: {{ addr_list|first() }}
    - names:
        - {{ id }}
{% endif %}
{% endfor %}
