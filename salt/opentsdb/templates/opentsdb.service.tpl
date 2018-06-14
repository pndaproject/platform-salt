[Unit]
Description=opentsdb

[Service]
Type=simple
ExecStartPre=/opt/pnda/utils/register-service.sh opentsdb-internal {{ opentsdb_port }}
ExecStart={{ home }}/start.sh
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
