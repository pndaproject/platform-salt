[Unit]
Description=logserver service

[Service]
Type=simple
ExecStart={{ home_dir }}/logstash/bin/logstash -f {{ home_dir }}/logstash/collector.conf
Restart=always
RestartSec=2