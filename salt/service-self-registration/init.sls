service-self-registration-dir:
  file.directory:
    - name: /opt/pnda/utils
    - mode: 644
    - makedirs: True

service-self-registration-script:
  file.managed:
    - name: /opt/pnda/utils/register-service.sh
    - source: salt://service-self-registration/files/register-service.sh
    - mode: 755
    - require:
      - file: service-self-registration-dir
