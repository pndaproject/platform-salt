{% set pnda_user = pillar['pnda']['user'] %}
{% set pnda_password = pillar['pnda']['password_hash'] %}
{% set pnda_group = pillar['pnda']['group'] %}

pnda-create_pnda_user:
  user.present:
    - name: {{ pnda_user }}
    - password: {{ pnda_password }}

pnda-create_pnda_group:
  group.present:
    - name: {{ pnda_group }}
    - addusers:
      - {{ pnda_user }}