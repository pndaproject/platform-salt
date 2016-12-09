[Unit]
Description=Platform testing general zookeeper

[Service]
Type=oneshot
ExecStart={{ platform_testing_directory }}/{{platform_testing_package}}/venv/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin zookeeper --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--zconnect {{ kafka_zookeepers|join(',') }}"
