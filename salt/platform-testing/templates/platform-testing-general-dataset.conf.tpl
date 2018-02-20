description "Platform testing general dataset upstart script"
author      "PNDA team"
start on runlevel [2345]
task
env PYTHON_HOME={{ platform_testing_directory }}/{{platform_testing_package}}/venv
exec ${PYTHON_HOME}/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin dataset --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--data_service {{ data_service_hosts|join(',') }} --cluster_name {{ pnda_cluster }} --elk_ip {{ elk_hosts|join(',') }} --cron_interval {{ gobblin_cron_interval }} --gobblin_log_path {{ gobblin_log_path }} --metric_console {{ metric_console_hosts|join(',') }} --num_attempts {{ gobblin_retry_count }} --master_dataset_dir {{ pnda_master_dataset_location }} --quarantine_dir {{ pnda_quarantine_dataset_location }} --console_user {{ console_user }} --console_password {{ console_password }}"


