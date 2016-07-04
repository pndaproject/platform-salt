description "Platform testing general dm blackbox upstart script"
author      "PNDA team"
start on runlevel [2345]
task
exec python -B {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin dm_blackbox --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--dmendpoint {{ dm_hosts|join(',') }}"
