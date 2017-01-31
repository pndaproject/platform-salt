[Unit]
Description=Logstash
After=syslog.target

[Service]
Type=simple
ExecStart={{ install_dir }}/logstash/bin/logstash -f {{ install_dir }}/logstash/collector.conf
ExecStopPost=/bin/sleep 2

[Install]
WantedBy=multi-user.target
