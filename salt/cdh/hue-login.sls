{% set hue_server = salt['pnda.get_hosts_by_role']('HUE', 'HUE_SERVER')[0] %}

cdh-hue_script_copy:
  file.managed:
    - name: /tmp/hue-user-setup.sh
    - source: salt://cdh/templates/hue-user-setup.sh.tpl
    - mode: 755
    - template: jinja

cdh-hue_script_run:
  cmd.run:
    - name: if [ "`hostname -s`" = "{{ hue_server }}" ]; then /tmp/hue-user-setup.sh; fi
