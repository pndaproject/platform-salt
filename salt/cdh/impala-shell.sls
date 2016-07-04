{% set install_dir = '/opt/pnda' %}

include:
  - python-pip

cdh-impala_shell_python_deps:
  pip.installed:
    - pkgs:
      - pexpect
    - require:
      - pip: python-pip-install_python_pip

cdh-impala_shell_dir:
  file.directory:
    - name: {{ install_dir }}/impala-wrapper
    - makedirs: True

cdh-impala_shell_install:
  file.managed:
    - name: {{ install_dir }}/impala-wrapper/impala-shell
    - source: salt://cdh/templates/impala-shell.tpl
    - mode: 755
    - template: jinja

cdh-impala_shell_alt:
  alternatives.install:
    - name: impala-shell
    - link: /usr/bin/impala-shell
    - path: {{ install_dir }}/impala-wrapper/impala-shell
    - priority: 20

cdh-impala_shell_auto:
  alternatives.auto:
    - name: impala-shell
