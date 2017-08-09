[Unit]
Description=logserver service

[Service]
Type=simple
ExecStart={{ install_dir }}/logstash/bin/logstash -f {{ install_dir }}/logstash/collector.conf
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target