{% set pnda_user = pillar['pnda']['user'] %}
{% set pnda_password = pillar['pnda']['password_hash'] %}
{% set pnda_group = pillar['pnda']['group'] %}
{% set pnda_home_directory = pillar['pnda']['homedir'] %}

pnda-create_pnda_user:
  user.present:
    - name: {{ pnda_user }}
    - password: {{ pnda_password }}
    - home: {{ pnda_home_directory }}

pnda-create_pnda_group:
  group.present:
    - name: {{ pnda_group }}
    - addusers:
      - {{ pnda_user }}
