[Unit]
Description=Flink-History-Server Service

[Service]
Type=forking
WorkingDirectory={{ install_dir }}
ExecStart={{ install_dir }}/bin/historyserver.sh start
ExecStop={{ install_dir }}/bin/historyserver.sh stop
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target