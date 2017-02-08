[Unit]
Description=concole backend app

[Service]
Type=simple
LimitNOFILE=32768
Environment=HOSTNAME={{host_ip}}
Environment=PORT={{backend_app_port}}
ExecStart=/bin/node {{app_dir}}/app.js
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
