# Remove the 127.0.1.1 entry as it can prevent Cloudera from installing
hostsfile-comment-127.0.1.1-entry:
  file.replace:
    - name: '/etc/hosts'
    - pattern: '^(127.0.1.1.*)$'
    - repl: '#\1'
