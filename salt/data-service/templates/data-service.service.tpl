[Unit]
Description=dataset manager service

[Service]
Type=simple
User=hdfs
WorkingDirectory={{ install_dir }}/data-service
ExecStart={{ install_dir }}/data-service/venv/bin/python {{ install_dir }}/data-service/apiserver.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target