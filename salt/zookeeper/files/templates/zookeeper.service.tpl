[Unit]
Description=zookeeper centralized coordination service
After=systemd-readahead-collect.service systemd-readahead-replay.service

[Service]
Type=simple
RemainAfterExit=yes
LimitNOFILE=8192
ExecStartPre={{ conf_dir }}/../bin/zookeeper-service-startpre.sh
ExecStart={{ conf_dir }}/../bin/zookeeper-service-start.sh
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target