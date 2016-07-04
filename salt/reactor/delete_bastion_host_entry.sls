{% if data['name']|length > 0 %}
reactor-delete_bastion_host_entry:
  local.cmd.run:
    - arg:
      - sed -i -e "/[[:space:]]\+{{ data['name'] }}[[:space:]]*$/d" /etc/hosts
    - tgt: bastion
{% endif %}
