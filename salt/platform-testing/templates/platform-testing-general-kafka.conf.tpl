description "Platform testing general kafka upstart script"
author      "PNDA team"
start on runlevel [2345]
task
exec python -B {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin kafka --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--brokerlist {{ kafka_brokers|join(',') }} --zkconnect {{ kafka_zookeepers|join(',') }}"
