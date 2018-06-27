{% set ldap_server = pillar['security']['ldap_server'] %}

{% if ldap_server %}
{% set ldap_base_dn = pillar['security']['ldap_base_dn'] %}

ldap-client-nss-pam-ldapd:
  pkg.installed:
    - name: {{ pillar['nss-pam-ldapd']['package-name'] }}
    - version: {{ pillar['nss-pam-ldapd']['version'] }}

ldap-client-openldap-clients:
  pkg.installed:
    - name: {{ pillar['openldap-clients']['package-name'] }}
    - version: {{ pillar['openldap-clients']['version'] }}

ldap-client-link-server:
  cmd.run:
    - name: authconfig --enableldap --enableldapauth --ldapserver={{ ldap_server }} --ldapbasedn="{{ ldap_base_dn }}" --enablemkhomedir --update
    - require:
      - pkg: ldap-client-nss-pam-ldapd
      - pkg: ldap-client-openldap-clients

ldap-client-start_service:
  cmd.run:
    - name: 'service nslcd stop || echo already stopped; service nslcd start'
    - require:
      - cmd: ldap-client-link-server
{% endif %}
