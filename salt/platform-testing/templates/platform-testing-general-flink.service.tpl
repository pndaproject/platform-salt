[Unit]
Description=Platform testing general Flink

[Service]
Type=oneshot
ExecStart={{ platform_testing_directory }}/{{platform_testing_package}}/venv/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin flink --postjson http://{{ console_hosts|join(',') }}/metrics --extra "--fhendpoint {{ fh_hosts|join(',') }}"
