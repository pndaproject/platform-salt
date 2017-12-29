[Unit]
Description=deployment manager service

[Service]
Type=simple
WorkingDirectory={{ install_dir }}/deployment_manager
ExecStart={{ install_dir }}/deployment_manager/venv/bin/python {{ install_dir }}/deployment_manager/application_summary.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
