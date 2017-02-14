[Unit]
Description=Jupyter Hub Daemon

[Service]
Type=simple
WorkingDirectory={{ virtual_env_dir }}
ExecStart={{ virtual_env_dir }}/bin/jupyterhub --config={{ jupyterhub_config_dir }}/jupyterhub_config.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target