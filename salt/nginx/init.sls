nginx-pkg:
  pkg.installed:
    - name: {{ pillar['nginx']['package-name'] }}
    - version: {{ pillar['nginx']['version'] }}
    - ignore_epoch: True
    
{% if grains['os'] in ('RedHat', 'CentOS') %}
nginx_conf_file:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
{% endif %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
nginx-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable nginx
{%- endif %}

nginx-start_service:
  cmd.run:
    - name: 'service nginx stop || echo already stopped; service nginx start'