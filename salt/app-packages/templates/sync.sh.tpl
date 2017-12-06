#!/bin/bash

declare -A HDFS
EXISTING=$(sudo -u hdfs hdfs dfs -stat "%n" {{ app_packages_hdfs_path }}/* || : 2>/dev/null)
for e in ${EXISTING[@]}
do
  HDFS[$e]=
done
CANDIDATES=$(grep -v '^#' {{ app_packages_fs_path }})
TARGETS=()
for c in ${CANDIDATES[@]}
do
  if ! [[ ${HDFS[$c]+unassigned} ]]; then
    TARGETS+=($c)
    echo "Uploading new package ${c}"
    curl -fsO {{ mirror_url }}/$c
    [[ $? -ne 0 ]] && echo "Error downloading ${c} from mirror" && exit -1
    sudo -u hdfs hdfs dfs -put $c {{ app_packages_hdfs_path }}/
    [[ $? -ne 0 ]] && echo "Error uploading ${c} to HDFS" && exit -1
  fi
done
{% raw %}
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "Nothing to upload"
fi
{% endraw %}
