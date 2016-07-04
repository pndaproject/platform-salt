{% set keystone_user = salt['pillar.get']('keystone.user', '') %}
{% set keystone_password = salt['pillar.get']('keystone.password', '') %}
{% set keystone_account = salt['pillar.get']('keystone.tenant', '') %}
{% set keystone_url = salt['pillar.get']('keystone.auth_url', '') %}

{% set aws_region = salt['pillar.get']('aws.region', '') %}
{% set aws_key = salt['pillar.get']('aws.key', '') %}
{% set aws_secret_key = salt['pillar.get']('aws.secret', '') %}

{% set apps_container = salt['pillar.get']('pnda.apps_container', 'apps') %}
{% set apps_folder = salt['pillar.get']('pnda.apps_folder', 'releases') %}

{%- set data_logger_ip = salt['pnda.ip_addresses']('console_backend')[0] -%}
{%- set data_logger_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') -%}


{
    "SwiftRepository": {
        "access": {
            "account":"{{ keystone_account }}",
            "user": "{{ keystone_user }}",
            "key": "{{ keystone_password }}",
            "auth_url": "{{ keystone_url }}"
        },
        "container": {
            "container": "{{ apps_container }}",
            "path": "{{ apps_folder }}"
        }
    },
    "S3Repository": {
        "access": {
            "region": "{{ aws_region }}",
            "access_key": "{{ aws_key }}",
            "secret_access_key": "{{ aws_secret_key }}"
        },
        "container": {
            "bucket": "{{ apps_container }}",
            "path": "{{ apps_folder }}"
        }
    },
    "config": {
        "log_level":"INFO",
        "package_callback": "http://{{ data_logger_ip }}:{{ data_logger_port }}/packages"
    }

}

