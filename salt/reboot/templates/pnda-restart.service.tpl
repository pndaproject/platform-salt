[Unit]
Description=pnda restart

[Service]
Type=oneshot
WorkingDirectory={{ install_dir }}
ExecStart={{ install_dir }}/bin/python {{ install_dir }}/pnda_restart.py
