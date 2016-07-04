"""
Name:       install_sharedlib
Purpose:    Copy specific libraries into HDFS to be made available to all jobs.
            Must be run from host in the cluster.
            Exists separately from cm_setup so that cm_setup can run locally.

Author:     PNDA team

Created:    14/03/2016
"""
import sys
import os
import getopt
from pywebhdfs.webhdfs import PyWebHdfsClient


def sharedlib_install(name_node, webhdfs_port, authentic_user,
                      platform_dir, lib_path_list):
    # Setup a connection with hdfs using namenode.
    hdfs = PyWebHdfsClient(host=name_node, port=webhdfs_port,
                           user_name=authentic_user, timeout=None)
    # Create directory on hadoop file system (HDFS).
    hdfs.make_dir(platform_dir)
    # Creates a new file on HDFS and write contents from local FS.
    for path in lib_path_list:
        platform_file = '%s/%s' % (platform_dir, os.path.basename(path))
        print >> sys.stdout, 'Copying source file: %s to HDFS path %s' %\
                             (path, platform_file)
        with open(path) as file_data:
            hdfs.create_file(platform_file, file_data, overwrite=True)

###############################################################################


def cmd_help():
    """Display command-line option help"""
    print >> sys.stdout, str(sys.argv[0]) + \
        ' -n <name node ip or dns-name>' \
        ' -h <help>'

###############################################################################


def main(argv):
    if len(sys.argv) > 1:
        print >> sys.stdout, str(sys.argv)
    else:
        cmd_help()
        sys.exit(2)

    # Check values passed as command line parameters.
    try:
        opts = getopt.getopt(argv, 'hn:', ['node_ip='])[0]
    except getopt.GetoptError:
        cmd_help()
        sys.exit(2)
    # Parse values from command line parameters.
    namenode = 'localhost'
    for opt, arg in opts:
        if opt == '-h':
            cmd_help()
            sys.exit()
        elif opt in ('-n', '--node_ip'):
            namenode = arg
        else:
            cmd_help()
    # Go ahead and install required JARs into platform direcetory
    sharedlib_install(namenode,
                      '14000',
                      'hdfs',
                      'user/deployment/platform',
                      ['/opt/cloudera/parcels/CDH/lib/hbase/hbase-client.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/hbase-common.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/hbase-protocol.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/hbase-server.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/lib/htrace-core.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/hbase-hadoop-compat.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/hbase-it.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/hbase-prefix-tree.jar',
                       '/opt/cloudera/parcels/CDH/lib/hbase/lib/zookeeper.jar',
                       '/opt/cloudera/parcels/CDH/lib/pig/piggybank.jar'])

###############################################################################
if __name__ == "__main__":
    main(sys.argv[1:])
