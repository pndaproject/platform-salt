import sys
import os
import time
from pywebhdfs.webhdfs import PyWebHdfsClient

def setup_common_oozie_libs(name_node):
    webhdfs_port = '14000'
    webhdfs_user = 'hdfs'
    platform_dir = 'user/deployment/platform'
    lib_path_list = ['/usr/hdp/current/hbase-client/lib/hbase-client.jar',
                     '/usr/hdp/current/hbase-client/lib/hbase-common.jar',
                     '/usr/hdp/current/hbase-client/lib/hbase-protocol.jar',
                     '/usr/hdp/current/hbase-client/lib/hbase-server.jar',
                     '/usr/hdp/current/hbase-client/lib/htrace-core-3.1.0-incubating.jar',
                     '/usr/hdp/current/hbase-client/lib/hbase-hadoop-compat.jar',
                     '/usr/hdp/current/hbase-client/lib/hbase-it.jar',
                     '/usr/hdp/current/hbase-client/lib/hbase-prefix-tree.jar',
                     '/usr/hdp/current/hbase-client/lib/zookeeper.jar',
                     '/usr/hdp/current/pig-client/piggybank.jar',
                     '/usr/hdp/current/spark-client/lib/spark-examples.jar']

    # Setup a connection with hdfs using namenode.
    hdfs_client = PyWebHdfsClient(host=name_node, port=webhdfs_port, user_name=webhdfs_user, timeout=None)
    # Create directory on hadoop file system (HDFS).
    hdfs_client.make_dir(platform_dir)
    # Creates a new file on HDFS and write contents from local FS.
    for path in lib_path_list:
        platform_file = '%s/%s' % (platform_dir, os.path.basename(path))
        print 'Copying source file: %s to HDFS path %s' % (path, platform_file)
        with open(path) as file_data:
            try:
                hdfs_client.create_file(platform_file, file_data, overwrite=True)
            except Exception:
                print 'retrying HDFS copy command for %s' % platform_file
                time.sleep(5)
                hdfs_client.create_file(platform_file, file_data, overwrite=True)

if __name__ == '__main__':
    setup_common_oozie_libs(sys.argv[1])