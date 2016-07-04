{%- for node in nodes -%}
{%- if node.fqdn == salt['grains.get']('id') -%}
{{ node.id }}
{%- endif -%}
{%- endfor -%}
