[Unit]
Description=Platform testing general kafka

[Service]
Type=oneshot
ExecStart={{ platform_testing_directory }}/{{platform_testing_package}}/venv/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin kafka --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--brokerlist {{ kafka_brokers|join(',') }} --zkconnect {{ kafka_zookeepers|join(',') }} --prod2cons"
