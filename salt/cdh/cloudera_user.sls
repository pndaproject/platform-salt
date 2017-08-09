# Create the cloudera user
{% set cloudera = {'username': 'cloudera'} %}

cdh-create_cloudera_user:
  user.present:
    - name: {{ cloudera['username'] }}

cdh-add_cloudera_user_to_passwordless_sudoers:
  file.managed:
    - name: /etc/sudoers.d/cloudera
    - contents: '{{ cloudera['username'] }} ALL = (ALL) NOPASSWD: ALL'
    - require:
      - user: cdh-create_cloudera_user
