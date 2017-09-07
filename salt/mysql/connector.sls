{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set connector_package = 'mysql-connector-java-5.1.25.jar' %}
{% set connector_url = mirror_location + connector_package %}

{% if grains['os'] == 'Ubuntu' %}
mysql-connector-install-java-library:
  pkg.installed:
    - name: {{ pillar['libmysql-java']['package-name'] }}
    - version: {{ pillar['libmysql-java']['version'] }}
    - ignore_epoch: True
{% elif grains['os'] in ('RedHat', 'CentOS') %}
mysql-connector-create-dir:
  file.directory:
    - name: '/usr/share/java'

mysql-connector-install-java-library:
  cmd.run:
    - name: curl {{ connector_url }} > /usr/share/java/mysql-connector-java.jar
{% endif %}