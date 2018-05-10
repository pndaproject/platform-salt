[Unit]
Description={{ service_name }} service

[Service]
Type=simple
ExecStart={{ knox_bin_dir }}/{{ service }}.sh start
Restart=always
RestartSec=2
User={{ user }}
Group={{ group }}

[Install]
WantedBy=multi-user.target