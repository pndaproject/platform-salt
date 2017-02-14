[Unit]
Description=JMXProxy service

[Service]
Type=simple
ExecStart=/usr/lib/jvm/java-8-oracle/bin/java -jar {{ install_dir }}/jmxproxy.jar server {{ install_dir }}/etc/jmxproxy.yaml
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target