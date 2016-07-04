nginx-nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
