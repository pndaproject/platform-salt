firewall-flush:
  iptables.flush

firewall-disable-saved-rules:
  file.replace:
    - name: /etc/rc.local
    - pattern: '^(.*)iptables.conf(.*)'
    - repl: ''