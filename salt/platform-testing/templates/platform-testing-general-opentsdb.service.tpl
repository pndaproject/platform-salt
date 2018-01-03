[Unit]
Description=Platform testing general opentsdb

[Service]
Type=oneshot
ExecStart={{ platform_testing_directory }}/{{platform_testing_package}}/venv/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin opentsdb --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--hosts {{ opentsdb_hosts|join(',') }}"
