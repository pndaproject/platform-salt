{% for service_name in data['data'] %}
{% if service_name != 'id' and not data['data'][service_name]['running'] %}
reactor-{{ service_name }}service_start:
  local.service.start:
    - tgt: {{ data['data']['id'] }} 
    - arg: 
      - {{ service_name }} 
{% endif %}
{% endfor %}
