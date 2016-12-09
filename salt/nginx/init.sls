nginx-pkg:
  pkg.installed:
    - name: nginx
{% if grains['os'] == 'RedHat' %}
nginx_conf_file:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
{% endif %}
nginx-service:
  service.running:
    - name: nginx
    - enable: True
{% if grains['os'] == 'RedHat' %}
    - watch:
      - file: nginx_conf_file
{% endif %}
