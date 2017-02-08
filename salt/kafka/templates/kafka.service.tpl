[Unit]
Description=kafka service

[Service]
Type=simple
LimitNOFILE=32768
WorkingDirectory={{ workdir }}
ExecStartPre=/bin/sleep 5
ExecStart={{ workdir }}/kafka-start-script.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target