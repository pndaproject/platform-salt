gobblin-require_gobblin_service_script:
  file.exists:
    - name: /usr/lib/systemd/system/gobblin.service

gobblin-systemctl_redhat_start:
  cmd.run:
    - name: /bin/systemctl start gobblin
    - require:
      - file: gobblin-require_gobblin_service_script 

gobblin-add_gobblin_crontab_entry:
  cron.present:
    - identifier: GOBBLIN
    - name: /bin/systemctl start gobblin
    - user: root
    - minute: 0,30
    - require:
      - file: gobblin-require_gobblin_service_script
