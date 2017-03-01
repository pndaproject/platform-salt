{% set virtual_env_dir = pillar['pnda']['homedir'] + "/impala-wrapper" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

include:
  - python-pip

cdh-impala_shell_venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - python: python2
    - requirements: salt://cdh/files/impala-shell-requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

cdh-impala_shell_install:
  file.managed:
    - name: {{ virtual_env_dir }}/impala-shell
    - source: salt://cdh/templates/impala-shell.tpl
    - mode: 755
    - template: jinja
    - defaults:
        virtual_env_dir: {{ virtual_env_dir }}
    - require:
      - virtualenv: cdh-impala_shell_venv

cdh-impala_shell_alt:
  alternatives.install:
    - name: impala-shell
    - link: /usr/bin/impala-shell
    - path: {{ virtual_env_dir}}/impala-shell
    - priority: 20
    - require:
      - file: cdh-impala_shell_install

cdh-impala_shell_auto:
  alternatives.auto:
    - name: impala-shell
    - require:
      - alternatives: cdh-impala_shell_alt
