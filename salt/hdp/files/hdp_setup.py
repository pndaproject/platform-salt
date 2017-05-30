"""
Name:       hdp_setup
Purpose:    Drives the Ambari API to create a cluster and configure
            the various component services such as HDFS, HBase etc

Author:     PNDA team

Created:    15/05/2017
"""

import logging
import time
import requests

DEFAULT_LOG_FILE = '/var/log/pnda/hadoop_setup.log'

logging.basicConfig(filename=DEFAULT_LOG_FILE,
                    level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def setup_hadoop(
        ambari_host,
        nodes,
        cluster_name,
        ambari_username='admin',
        ambari_password='admin',
        hdp_core_stack_repo=None,
        hdp_utils_stack_repo=None,
        anaconda_repo=None,
        anaconda_version=None):

    logging.info("setup_hadoop:")
    logging.info(ambari_host)
    logging.info(nodes)
    logging.info(cluster_name)
    logging.info(ambari_username)
    logging.info(ambari_password)
    logging.info(hdp_core_stack_repo)
    logging.info(hdp_utils_stack_repo)
    logging.info(anaconda_repo)
    logging.info(anaconda_version)

    ambari_api = 'http://%s:8080/api/v1' % ambari_host
    headers = {'X-Requested-By': ambari_username}

    logging.info("Waiting for Ambari API to be up")
    api_up = False
    for _ in xrange(120):
        try:
            logging.info("Checking API availability....")
            response = requests.get("%s/hosts" % ambari_api, timeout=5, auth=(ambari_username, ambari_password), headers=headers)
            logging.debug("%s" % response.text)
            api_up = True
            break
        except Exception:
            logging.warning("API is not up")
            time.sleep(5)

    def exit_setup(error_message):
        logging.error(error_message)
        raise Exception(error_message)

    if api_up is False:
        exit_setup("The API did not come up: %s" % ambari_api)

    logging.info("Configuring Ambari to use HDP stack repos")

    if 'ubuntu14' in hdp_core_stack_repo:
        hdp_os_type = 'ubuntu14'
    elif 'centos7' in hdp_core_stack_repo:
        hdp_os_type = 'redhat7'
    else:
        exit_setup('Expected ubuntu14 or centos7 in hdp_core_stack_repo but found: %s' % hdp_core_stack_repo)

    repo_requests = [('%s/stacks/HDP/versions/2.6/operating_systems/%s/repositories/HDP-2.6' % (ambari_api, hdp_os_type),
                      '{"Repositories" : { "base_url" : "%s", "verify_base_url" : true }}' % hdp_core_stack_repo),
                     ('%s/stacks/HDP/versions/2.6/operating_systems/%s/repositories/HDP-UTILS-1.1.0.21' % (ambari_api, hdp_os_type),
                      '{"Repositories" : { "base_url" : "%s", "verify_base_url" : true }}' % hdp_utils_stack_repo)]

    for repo_request in repo_requests:
        logging.debug("Registering repo: %s" % repo_request[0])
        response = requests.put(repo_request[0], repo_request[1],
                                auth=(ambari_username, ambari_password), headers=headers)
        if response.status_code != 200:
            exit_setup(response.text)
        logging.debug("Registered repo: %s" % repo_request[0])

    logging.info("Creating blueprint")
    blueprint = '''{
	                "configurations": [
                        {
                            "hive-env" : {
                                "properties" : {
                                "hive_ambari_database" : "MySQL",
                                "hive_ambari_host" : "%(s)s-hadoop-mgr-1",
                                "hive_database" : "MySQL Database",
                                "hive_database_name" : "hive",
                                "hive_database_type" : "mysql",
                                "hive_existing_mssql_server_2_host" : "%(s)s-hadoop-mgr-1",
                                "hive_existing_mssql_server_host" : "%(s)s-hadoop-mgr-1",
                                "hive_existing_mysql_host" : "%(s)s-hadoop-mgr-1",
                                "hive_hostname" : "%(s)s-hadoop-mgr-1",
                                "hive_user" : "hive",
                                "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                                "javax.jdo.option.ConnectionPassword" : "hive",
                                "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(s)s-hadoop-mgr-1/hive",
                                "javax.jdo.option.ConnectionUserName" : "hive"
                                }
                            }
                        },
                        {
                            "hive-site" : {
                                "properties" : {
                                "javax.jdo.option.ConnectionDriverName" : "com.mysql.jdbc.Driver",
                                "javax.jdo.option.ConnectionPassword" : "hive",
                                "javax.jdo.option.ConnectionURL" : "jdbc:mysql://%(s)s-hadoop-mgr-1/hive?createDatabaseIfNotExist=true",
                                "javax.jdo.option.ConnectionUserName" : "hive"
                                }
                            }
                        }
                    ],
                    "host_groups" : [
                        {
                        "name" : "master",
                        "components" : [
                            {
                            "name" : "METRICS_MONITOR"
                            },
                            {
                            "name" : "ZOOKEEPER_SERVER"
                            },
                            {
                            "name" : "NAMENODE"
                            },
                            {
                            "name" : "SECONDARY_NAMENODE"
                            },
                            {
                            "name" : "HBASE_MASTER"
                            },
                            {
                            "name" : "RESOURCEMANAGER"
                            },
                            {
                            "name" : "HISTORYSERVER"
                            },
                            {
                            "name" : "SPARK_JOBHISTORYSERVER"
                            },
                            {
                            "name" : "APP_TIMELINE_SERVER"
                            },
                            {
                            "name" : "HIVE_SERVER"
                            },
                            {
                            "name" : "HIVE_METASTORE"
                            },
                            {
                            "name" : "WEBHCAT_SERVER"
                            },
                            {
                            "name" : "FALCON_SERVER"
                            },
                            {
                            "name" : "OOZIE_SERVER"
                            },
                            {
                            "name" : "HDFS_CLIENT"
                            },
                            {
                            "name" : "YARN_CLIENT"
                            },
                            {
                            "name" : "MAPREDUCE2_CLIENT"
                            },
                            {
                            "name" : "ZOOKEEPER_CLIENT"
                            },
                            {
                            "name" : "PIG"
                            },
                            {
                            "name" : "TEZ_CLIENT"
                            },
                            {
                            "name" : "OOZIE_CLIENT"
                            }
                        ],
                        "cardinality" : "1"
                        },
                        {
                        "name" : "slaves",
                        "components" : [
                            {
                            "name" : "METRICS_MONITOR"
                            },
                            {
                            "name" : "DATANODE"
                            },
                            {
                            "name" : "NODEMANAGER"
                            },
                            {
                            "name" : "HBASE_REGIONSERVER"
                            },
                            {
                            "name" : "HDFS_CLIENT"
                            },
                            {
                            "name" : "YARN_CLIENT"
                            },
                            {
                            "name" : "MAPREDUCE2_CLIENT"
                            },
                            {
                            "name" : "ZOOKEEPER_CLIENT"
                            }
                        ],
                        "cardinality" : "1+"
                        },
                        {
                        "name" : "edge",
                        "components" : [
                            {
                            "name" : "METRICS_MONITOR"
                            },
                            {
                            "name" : "METRICS_COLLECTOR"
                            },
                            {
                            "name" : "ZOOKEEPER_CLIENT"
                            },
                            {
                            "name" : "PIG"
                            },
                            {
                            "name" : "OOZIE_CLIENT"
                            },
                            {
                            "name" : "HBASE_CLIENT"
                            },
                            {
                            "name" : "HCAT"
                            },
                            {
                            "name" : "KNOX_GATEWAY"
                            },
                            {
                            "name" : "FALCON_CLIENT"
                            },
                            {
                            "name" : "TEZ_CLIENT"
                            },
                            {
                            "name" : "SPARK_CLIENT"
                            },
                            {
                            "name" : "SLIDER"
                            },
                            {
                            "name" : "SQOOP"
                            },
                            {
                            "name" : "HDFS_CLIENT"
                            },
                            {
                            "name" : "HIVE_CLIENT"
                            },
                            {
                            "name" : "YARN_CLIENT"
                            },
                            {
                            "name" : "MAPREDUCE2_CLIENT"
                            }
                        ],
                        "cardinality" : "1+"
                        }
                    ],
                    "Blueprints" : {
                        "blueprint_name" : "hdp-sample-blueprint",
                        "stack_name" : "HDP",
                        "stack_version" : "2.6"
                    }
                }''' % {'s': cluster_name}
    response = requests.post('%s/blueprints/hdp-sample-blueprint' % ambari_api, blueprint, auth=(ambari_username, ambari_password), headers=headers)
    logging.info('Response to blueprint creation %s: %s' % ('/blueprints/hdp-sample-blueprint', response.status_code))

    cluster_instance = '''{
                            "blueprint" : "hdp-sample-blueprint",
                            "default_password" : "%s",
                            "host_groups" :[
                                {
                                  "name" : "master",
                                  "hosts" : [
                                    {
                                    "fqdn" : "%s-hadoop-mgr-1"
                                    }
                                ]
                                },
                                {
                                  "name" : "slaves",
                                  "hosts" : [
                                    {
                                    "fqdn" : "%s-hadoop-dn-0"
                                    }
                                  ]
                                },
                                {
                                  "name" : "edge",
                                  "hosts" : [
                                    {
                                    "fqdn" : "%s-hadoop-edge"
                                    }
                                ]
                                }
                            ]
                        }''' % (ambari_password, cluster_name, cluster_name, cluster_name)

    response = requests.post('%s/clusters/hdp-sample-pico-cluster' %
                             ambari_api, cluster_instance, auth=(ambari_username, ambari_password), headers=headers)
    logging.info('Response to cluster creation %s: %s' % ('/clusters/hdp-sample-pico-cluster', response.status_code))
    logging.info(response.text)
