{% set old_cn = salt['pillar.get']('old_cn') %}
{% set new_cn = salt['pillar.get']('new_cn') %}
{% set ip_addr = salt['pillar.get']('ip_addr') %}

{% if old_cn != None %}
reactor-remove_old_fqdn_entry:
  host.absent:
    - name: {{ old_cn }}
    - ip: {{ ip_addr }}
{% endif %}

{% if new_cn != None %}
reactor-add:
  host.present:
    - name: {{ new_cn }}
    - ip: {{ ip_addr }}
{% endif %}
