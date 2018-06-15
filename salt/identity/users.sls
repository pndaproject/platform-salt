{% set ldap_server = pillar['security']['ldap_server'] %}
{% if not ldap_server %}
{% for usr in pillar['identity']['users'] %}

{% set user = usr['user'] %}
{% set password = usr['password_hash'] %}
{% set group = usr['group'] %}
{% set pnda_group = pillar['pnda']['group'] %}

pnda-create_{{ group }}_group:
  group.present:
    - name: {{ group }}

pnda-create_{{ user }}_user:
  user.present:
    - name: {{ user }}
    - password: {{ password }}
    - createhome: False
    - gid: {{ group }}
    - groups:
      - {{ pnda_group }}

{% endfor %}
{% endif %}