[Unit]
Description=pnda restart

[Service]
Type=once
ExecStart=/bin/python {{ install_dir }}/pnda_restart.py
ExecStopPost=/bin/sleep 2
