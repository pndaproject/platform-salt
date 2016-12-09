[Unit]
Description=Linked-in Gobblin MRv2 application: PNDA pull

[Service]
Type=oneshot
UMask=022
User={{ gobblin_user }}
Environment=JAVA_HOME="/usr/lib/jvm/java-8-oracle/"
Environment=HADOOP_BIN_DIR="/opt/cloudera/parcels/CDH/bin"
WorkingDirectory={{ gobblin_directory_name }}
ExecStart=bash ./bin/gobblin-mapreduce.sh --conf {{ gobblin_job_file }} --logdir /var/log/pnda/gobblin --workdir "{{ gobblin_work_dir }}" --jars $(ls lib/*.jar | tr '\n' ',')
