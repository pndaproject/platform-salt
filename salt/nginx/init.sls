{% set console_port = pillar['console_frontend']['bind_port'] %}

nginx-pkg:
  pkg.installed:
    - name: {{ pillar['nginx']['package-name'] }}
    - version: {{ pillar['nginx']['version'] }}
    - ignore_epoch: True
    
nginx_conf_file:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf

nginx-service-script:
  file.managed:
    - name: /usr/lib/systemd/system/nginx.service
    - source: salt://{{ sls }}/templates/nginx.service.tpl
    - mode: 0644
    - template: jinja
    - context:
        console_port: {{ console_port }}

nginx-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable nginx

nginx-start_service:
  cmd.run:
    - name: 'service nginx stop || echo already stopped; service nginx start'