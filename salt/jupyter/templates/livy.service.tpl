[Unit]
Description=livy service

[Service]
Environment="SPARK_HOME={{ spark_home }}"
Environment="HADOOP_CONF_DIR={{ hadoop_conf_dir }}"
User=pnda
Group=pnda
Type=simple
WorkingDirectory={{ install_dir }}
ExecStart={{ install_dir }}/bin/livy-server
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
