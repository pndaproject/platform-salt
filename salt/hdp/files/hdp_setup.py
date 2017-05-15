"""
Name:       hdp_setup
Purpose:    Drives the Ambari API to create a cluster and configure
            the various component services such as HDFS, HBase etc

Author:     PNDA team

Created:    15/05/2017
"""

import logging

DEFAULT_LOG_FILE = '/var/log/pnda/hadoop_setup.log'

logging.basicConfig(filename=DEFAULT_LOG_FILE,
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def setup_hadoop(
        ambari_api,
        nodes,
        cluster_name,
        ambari_username='admin',
        ambari_password='admin',
        hdp_core_stack_repo=None,
        hdp_utils_stack_repo=None,
        anaconda_repo=None,
        anaconda_version=None):

    logging.info("Doesn't do anything yet, here are the parameters:")
    logging.info(ambari_api)
    logging.info(nodes)
    logging.info(cluster_name)
    logging.info(ambari_username)
    logging.info(ambari_password)
    logging.info(hdp_core_stack_repo)
    logging.info(hdp_utils_stack_repo)
    logging.info(anaconda_repo)
    logging.info(anaconda_version)


