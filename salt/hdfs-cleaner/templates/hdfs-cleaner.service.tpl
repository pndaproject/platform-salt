[Unit]
Description=HDFS cleaner task

[Service]
Type=oneshot
UMask=022
User=hdfs
WorkingDirectory={{ install_dir }}/hdfs-cleaner
ExecStart={{ install_dir }}/hdfs-cleaner/venv/bin/python {{ install_dir }}/hdfs-cleaner/hdfs-cleaner.py
