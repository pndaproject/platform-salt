task
setuid hdfs
env programDir={{ install_dir }}/hdfs-cleaner
chdir {{ install_dir }}/hdfs-cleaner
exec python ${programDir}/hdfs-cleaner.py