{% set user = pillar['user']  %}
{% set group = pillar['group']  %}
{% set user_home =  '/home/' + user %}
{% set pnda_home = salt['pillar.get']('pnda:homedir', '') %}

jupyter-create_notebooks_directory:
  file.directory:
    - name: '{{ user_home }}/jupyter_notebooks'
    - makedirs: True
    - user: {{ user }}
    - group: {{ group }}
    - mode: 700

jupyter-link_initial_notebooks:
  file.symlink:
    - name: '{{ user_home }}/jupyter_notebooks/examples'
    - target: '{{ pnda_home }}/jupyter_notebooks'
    - user: {{ user }}
    - group: {{ group }}
    - mode: 700
