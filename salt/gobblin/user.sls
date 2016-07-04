{% set gobblin_user = "gobblin" %}
{% set pnda_group = pillar['pnda']['group'] %}

gobblin-create_gobblin_user:
  user.present:
    - name: {{ gobblin_user }}
    - groups:
      - {{ pnda_group }}

