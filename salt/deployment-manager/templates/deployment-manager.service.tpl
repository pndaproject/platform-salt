[Unit]
Description=deployment manager service

[Service]
Type=simple
WorkingDirectory={{ install_dir }}/deployment_manager
ExecStartPre=/opt/pnda/utils/register-service.sh deployment-manager-internal 5000
ExecStart={{ install_dir }}/deployment_manager/venv/bin/python {{ install_dir }}/deployment_manager/app.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target