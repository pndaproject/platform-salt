include:
  - self-registration

self-registration-service-script:
  file.managed:
    - name: /opt/pnda/utils/register-service.sh
    - source: salt://self-registration/files/register-service.sh
    - mode: 755
    - require:
      - file: self-registration-dir
