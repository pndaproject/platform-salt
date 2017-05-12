[Unit]
Description=Platform testing hdp

[Service]
Type=oneshot
ExecStart={{ platform_testing_directory }}/{{platform_testing_package}}/venv/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin hdp --postjson http://{{ console_hoststring }}/metrics --extra "--cmhost {{ cm_hoststring }} --cmport {{ cm_port }} --cmuser {{ cm_username }} --cmpassword {{ cm_password }} --cluster_name {{ cluster_name }}"
