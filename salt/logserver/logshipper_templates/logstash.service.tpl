[Unit]
Description=Logstash

[Service]
Type=simple
ExecStart={{ install_dir }}/logstash/bin/logstash --path.data {{ install_dir }}/logstash/logshipper-data -f {{ install_dir }}/logstash/shipper.conf
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
