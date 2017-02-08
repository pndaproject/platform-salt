[Unit]
Description=kafka manager

[Service]
Type=simple
LimitNOFILE=8192
ExecStart=/opt/pnda/kafka-manager/bin/kafka-manager -Dconfig.file=/opt/pnda/kafka-manager/conf/application.conf -Dapplication.home=/opt/pnda/kafka-manager -Dhttp.port={{ kafka_manager_port }}
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target