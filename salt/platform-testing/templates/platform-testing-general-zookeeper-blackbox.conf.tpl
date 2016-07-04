description "Platform testing general zookeeper upstart script"
author      "PNDA team"
start on runlevel [2345]
task
exec python -B {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin zookeeper_blackbox --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--zconnect {{ kafka_zookeepers|join(',') }}"
