motd-install:
  file.managed:
    - name: /etc/motd
    - user: root
    - group: root
    - mode: 0644
    - source: salt://motd/motd
