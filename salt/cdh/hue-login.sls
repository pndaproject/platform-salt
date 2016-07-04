cdh-hue_script_copy:
  file.managed:
    - name: /tmp/hue-user-setup.sh
    - source: salt://cdh/templates/hue-user-setup.sh.tpl
    - mode: 755
    - template: jinja

cdh-hue_script_run:
  cmd.script:
    - name: hue-user-setup
    - source: /tmp/hue-user-setup.sh
    - cwd: /