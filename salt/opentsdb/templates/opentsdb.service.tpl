[Unit]
Description=opentsdb

[Service]
Type=simple
ExecStart={{ home }}/start.sh
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
