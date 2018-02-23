[Unit]
Description=logserver service

[Service]
Type=simple
ExecStart={{ install_dir }}/logstash/bin/logstash --path.data {{ install_dir }}/logstash/logserver-data -f {{ install_dir }}/logstash/collector.conf
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target