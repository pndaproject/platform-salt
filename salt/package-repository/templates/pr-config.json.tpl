{%- set package_repository_fs_type = salt['pillar.get']('package_repository:fs_type', '') -%}
{%- set data_logger_ip = salt['pnda.get_hosts_for_role']('console_backend_data_logger')[0] -%}
{%- set data_logger_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') -%}

{
{% if package_repository_fs_type == 'swift' %}
    "SwiftRepository": {
        "access": {
            "account":"{{ salt['pillar.get']('keystone.tenant', '') }}",
            "user": "{{ salt['pillar.get']('keystone.user', '') }}",
            "key": "{{ salt['pillar.get']('keystone.password', '') }}",
            "auth_url": "{{ salt['pillar.get']('keystone.auth_url', '') }}",
            "auth_version": "{{ salt['pillar.get']('keystone.auth_version', '2') }}"
        },
        "container": {
            "container": "{{ salt['pillar.get']('pnda.apps_container', 'apps') }}",
            "path": "{{ salt['pillar.get']('pnda.apps_folder', 'releases') }}"
        }
    },
{% elif package_repository_fs_type == 's3' %}
    "S3Repository": {
        "access": {
            "region": "{{ salt['pillar.get']('aws.apps_region', '') }}",
            "access_key": "{{ salt['pillar.get']('aws.apps_key', '') }}",
            "secret_access_key": "{{ salt['pillar.get']('aws.apps_secret', '') }}"
        },
        "container": {
            "bucket": "{{ salt['pillar.get']('pnda.apps_container', 'apps') }}",
            "path": "{{ salt['pillar.get']('pnda.apps_folder', 'releases') }}"
        }
    },
{% else %}
    "FsRepository": {
        "location": {
            "path": "{{ salt['pillar.get']('package_repository:fs_location_path', '/mnt/packages') }}"
        }
    },
{% endif %}
    "config": {
        "log_level":"INFO",
        "package_callback": "http://{{ data_logger_ip }}:{{ data_logger_port }}/packages"
    }

}

