"""
Name:       hdp_setup
Purpose:    Drives the Ambari API to create a cluster and configure
            the various component services such as HDFS, HBase etc

Author:     PNDA team

Created:    15/05/2017
"""

import logging
import requests

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

    logging.info("setup_hadoop:")
    logging.info(ambari_api)
    logging.info(nodes)
    logging.info(cluster_name)
    logging.info(ambari_username)
    logging.info(ambari_password)
    logging.info(hdp_core_stack_repo)
    logging.info(hdp_utils_stack_repo)
    logging.info(anaconda_repo)
    logging.info(anaconda_version)

    logging.info("Configuring Ambari to use HDP stack repos")

    if 'ubuntu14' in hdp_core_stack_repo:
        hdp_os_type = 'ubuntu14'
    elif 'centos7' in hdp_core_stack_repo:
        hdp_os_type = 'centos7'
    else:
        raise Exception('Expected ubuntu14 or centos7 in hdp_core_stack_repo but found: %s' % hdp_core_stack_repo)

    repo_requests = [('http://%s:8080/api/v1/stacks/HDP/versions/2.6/operating_systems/%s/repositories/HDP-2.6' % (ambari_api, hdp_os_type),
                      '{"Repositories" : { "base_url" : "%s", "verify_base_url" : true }}' % hdp_core_stack_repo),
                      ('http://%s:8080/api/v1/stacks/HDP/versions/2.6/operating_systems/%s/repositories/HDP-UTILS-1.1.0.21' % (ambari_api, hdp_os_type),
                      '{"Repositories" : { "base_url" : "%s", "verify_base_url" : true }}' % hdp_utils_stack_repo)]

    headers = {'X-Requested-By': ambari_username}
    for repo_request in repo_requests:
        response = requests.put(repo_request[0], repo_request[1], 
                                auth=(ambari_username, ambari_password), headers=headers)
        if response.status_code != 200:
            raise Exception(response.text)