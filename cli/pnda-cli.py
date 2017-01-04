#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#   Copyright (c) 2016 Cisco and/or its affiliates.
#   This software is licensed to you under the terms of the Apache License, Version 2.0
#   (the "License").
#   You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#   The code, technical concepts, and all information contained herein, are the property of
#   Cisco Technology, Inc.and/or its affiliated entities, under various laws including copyright,
#   international treaties, patent, and/or contract.
#   Any use of the material herein must be in accordance with the terms of the License.
#   All rights not expressly granted by the License are reserved.
#   Unless required by applicable law or agreed to separately in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
#   ANY KIND, either express or implied.
#
#   Purpose: Script to create PNDA on Amazon Web Services EC2

import uuid
import re
import sys
import os
import os.path
import json
import time
import logging
import atexit
import traceback
import datetime
import tarfile
import Queue
from threading import Thread

import argparse
from argparse import RawTextHelpFormatter
import requests
import boto.cloudformation
import boto.ec2
import yaml

import subprocess_to_log


os.chdir(os.path.dirname(os.path.abspath(__file__)))

LOG_FILE_NAME = 'logs/pnda-cli.%s.log' % time.time()
logging.basicConfig(filename=LOG_FILE_NAME,
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')
LOG = logging.getLogger('everything')
CONSOLE = logging.getLogger('console')
CONSOLE.addHandler(logging.StreamHandler())

NAME_REGEX = r"^[\.a-zA-Z0-9-]+$"
VALIDATION_RULES = None
NODE_CONFIG = None
PNDA_ENV = None
VALID_FLAVORS = None
START = datetime.datetime.now()
THROW_BASH_ERROR = "cmd_result=${PIPESTATUS[0]} && if [ ${cmd_result} != '0' ]; then exit ${cmd_result}; fi"

RUNFILE = None
def init_runfile(cluster):
    global RUNFILE
    RUNFILE = 'cli/logs/%s.%s.run' % (cluster, int(time.time()))

def to_runfile(pairs):
    '''
    Append arbitrary pairs to a JSON dict on disk from anywhere in the code
    '''
    mode = 'w' if not os.path.isfile(RUNFILE) else 'r'
    with open(RUNFILE, mode) as runfile:
        jrf = json.load(runfile) if mode == 'r' else {}
        jrf.update(pairs)
        json.dump(jrf, runfile)

def banner():
    print r"    ____  _   ______  ___ "
    print r"   / __ \/ | / / __ \/   |"
    print r"  / /_/ /  |/ / / / / /| |"
    print r" / ____/ /|  / /_/ / ___ |"
    print r"/_/   /_/ |_/_____/_/  |_|"
    print r""

@atexit.register
def display_elasped():
    blue = '\033[94m'
    reset = '\033[0m'
    elapsed = datetime.datetime.now() - START
    CONSOLE.info("%sTotal execution time: %s%s", blue, str(elapsed), reset)


def generate_template_file(flavor, datanodes, opentsdbs, kafkas, zookeepers, esmasters, esingests, esdatas, escoords, esmultis, logstashNodes):
    common_filepath = 'cloud-formation/cf-common.json'
    with open(common_filepath, 'r') as template_file:
        template_data = json.loads(template_file.read())

    flavor_filepath = 'cloud-formation/%s/cf-flavor.json' % flavor
    with open(flavor_filepath, 'r') as template_file:
        flavor_data = json.loads(template_file.read())

    for element in flavor_data:
        if element not in template_data:
            template_data[element] = flavor_data[element]
        else:
            for child in flavor_data[element]:
                template_data[element][child] = flavor_data[element][child]

    instance_cdh_dn = json.dumps(template_data['Resources'].pop('instanceCdhDn'))
    if 'instanceOpenTsdb' in template_data['Resources']:
        instance_open_tsdb = json.dumps(template_data['Resources'].pop('instanceOpenTsdb'))
    if 'instanceKafka' in template_data['Resources']:
        instance_kafka = json.dumps(template_data['Resources'].pop('instanceKafka'))
    if 'instanceZookeeper' in template_data['Resources']:
        instance_zookeeper = json.dumps(template_data['Resources'].pop('instanceZookeeper'))
    if 'instanceESMaster' in template_data['Resources']:
        instance_esmaster = json.dumps(template_data['Resources'].pop('instanceESMaster'))
    if 'instanceESData' in template_data['Resources']:
        instance_esdata = json.dumps(template_data['Resources'].pop('instanceESData'))
    if 'instanceESIngest' in template_data['Resources']:
        instance_esingest = json.dumps(template_data['Resources'].pop('instanceESIngest'))
    if 'instanceESCoordinator' in template_data['Resources']:
        instance_escoordinator = json.dumps(template_data['Resources'].pop('instanceESCoordinator'))
    if 'instanceESMulti' in template_data['Resources']:
        instance_esmulti = json.dumps(template_data['Resources'].pop('instanceESMulti'))
    if 'instanceLogstash' in template_data['Resources']:
        instance_logstash = json.dumps(template_data['Resources'].pop('instanceLogstash'))

    for datanode in range(0, datanodes):
        instance_cdh_dn_n = instance_cdh_dn.replace('$node_idx$', str(datanode))
        template_data['Resources']['instanceCdhDn%s' % datanode] = json.loads(instance_cdh_dn_n)

    for opentsdb in range(0, opentsdbs):
        instance_open_tsdb_n = instance_open_tsdb.replace('$node_idx$', str(opentsdb))
        template_data['Resources']['instanceOpenTsdb%s' % opentsdb] = json.loads(instance_open_tsdb_n)

    for kafka in range(0, kafkas):
        instance_kafka_n = instance_kafka.replace('$node_idx$', str(kafka))
        template_data['Resources']['instanceKafka%s' % kafka] = json.loads(instance_kafka_n)

    for zookeeper in range(0, zookeepers):
        instance_zookeeper_n = instance_zookeeper.replace('$node_idx$', str(zookeeper))
        template_data['Resources']['instanceZookeeper%s' % zookeeper] = json.loads(instance_zookeeper_n)

    for esmaster in range(0, esmasters):
        instance_esmaster_n = instance_esmaster.replace('$node_idx$', str(esmaster))
        template_data['Resources']['instanceESMaster%s' % esmaster] = json.loads(instance_esmaster_n)
    
    for esingest in range(0, esingests):
        instance_esingest_n = instance_esingest.replace('$node_idx$', str(esingest))
        template_data['Resources']['instanceESIngest%s' % esingest] = json.loads(instance_esingest_n)
    
    for esdata in range(0, esdatas):
        instance_esdata_n = instance_esdata.replace('$node_idx$', str(esdata))
        template_data['Resources']['instanceESData%s' % esdata] = json.loads(instance_esdata_n)
    
    for escoord in range(0, escoords):
        instance_escoordinator_n = instance_escoordinator.replace('$node_idx$', str(escoord))
        template_data['Resources']['instanceESCoordinator%s' % escoord] = json.loads(instance_escoordinator_n)

    for esmulti in range(0, esmultis):
        instance_esmulti_n = instance_esmulti.replace('$node_idx$', str(esmulti))
        template_data['Resources']['instanceESMulti%s' % esmulti] = json.loads(instance_esmulti_n)

    for eslogstash in range(0, logstashNodes):
        instance_logstash_n = instance_logstash.replace('$node_idx$', str(eslogstash))
        template_data['Resources']['instanceLogstash%s' % eslogstash] = json.loads(instance_logstash_n)

    return json.dumps(template_data)

def get_instance_map(cluster):
    CONSOLE.debug('Checking details of created instances')
    region = PNDA_ENV['ec2_access']['AWS_REGION']
    ec2 = boto.ec2.connect_to_region(region)
    reservations = ec2.get_all_reservations()
    instance_map = {}
    for reservation in reservations:
        for instance in reservation.instances:
            if 'pnda_cluster' in instance.tags and instance.tags['pnda_cluster'] == cluster and instance.state == 'running':
                CONSOLE.debug(instance.private_ip_address, ' ', instance.tags['Name'])
                instance_map[instance.tags['Name']] = {
                    "public_dns": instance.public_dns_name,
                    "ip_address": instance.ip_address,
                    "private_ip_address":instance.private_ip_address,
                    "name": instance.tags['Name'],
                    "node_idx": instance.tags['node_idx'],
                    "node_type": instance.tags['node_type']
                }
    return instance_map

def get_current_node_counts(cluster):
    CONSOLE.debug('Counting existing instances')
    node_counts = {'zk':0, 'kafka':0, 'cdh-dn':0, 'opentsdb':0}
    for _, instance in get_instance_map(cluster).iteritems():
        if instance['node_type'] in node_counts:
            current_count = node_counts[instance['node_type']]
        else:
            current_count = 0
        node_counts[instance['node_type']] = current_count + 1
    return node_counts

def scp(files, cluster, host):
    cmd = "scp -F cli/ssh_config-%s %s %s:%s" % (cluster, ' '.join(files), host, '/tmp')
    CONSOLE.debug(cmd)
    ret_val = subprocess_to_log.call(cmd.split(' '), LOG, host)
    if ret_val != 0:
        raise Exception("Error transferring files to new host %s via SCP. See debug log (%s) for details." % (host, LOG_FILE_NAME))

def ssh(cmds, cluster, host):
    cmd = "ssh -F cli/ssh_config-%s %s" % (cluster, host)
    parts = cmd.split(' ')
    parts.append(';'.join(cmds))
    CONSOLE.debug(json.dumps(parts))
    ret_val = subprocess_to_log.call(parts, LOG, host, scan_for_errors=[r'lost connection', r'\s*Failed:\s*[1-9].*'])
    if ret_val != 0:
        raise Exception("Error running ssh commands on host %s. See debug log (%s) for details." % (host, LOG_FILE_NAME))

def bootstrap(instance, saltmaster, cluster, flavor, branch, error_queue):
    ret_val = None
    try:
        ip_address = instance['private_ip_address']
        CONSOLE.debug('bootstrapping %s', ip_address)
        node_type = instance['node_type']
        type_script = 'bootstrap-scripts/%s/%s.sh' % (flavor, node_type)
        if not os.path.isfile(type_script):
            type_script = 'bootstrap-scripts/%s.sh' % (node_type)
        node_idx = instance['node_idx']
        scp(['cli/pnda_env_%s.sh' % cluster, 'bootstrap-scripts/base.sh', type_script], cluster, ip_address)
        ssh(['source /tmp/pnda_env_%s.sh' % cluster,
             'export PNDA_SALTMASTER_IP=%s' % saltmaster,
             'export PNDA_CLUSTER=%s' % cluster,
             'export PNDA_FLAVOR=%s' % flavor,
             'export PLATFORM_GIT_BRANCH=%s' % branch,
             'sudo chmod a+x /tmp/base.sh',
             '(sudo -E /tmp/base.sh 2>&1) | tee -a pnda-bootstrap.log; %s' % THROW_BASH_ERROR,
             'sudo chmod a+x /tmp/%s.sh' % node_type,
             # TODO: Add param to number of master of instances (perhaps hard coded in salt?)
             '(sudo -E /tmp/%s.sh %s 2>&1) | tee -a pnda-bootstrap.log; %s' % (node_type, node_idx, THROW_BASH_ERROR)], cluster, ip_address)
    except:
        ret_val = 'Error for host %s. %s' % (instance['name'], traceback.format_exc())
        CONSOLE.error(ret_val)
        error_queue.put(ret_val)

def check_config_file():
    if not os.path.exists('pnda_env.yaml'):
        CONSOLE.error('Missing required pnda_env.yaml config file, make a copy of pnda_env_example.yaml named pnda_env.yaml, fill it out and try again.')
        sys.exit(1)

def check_keypair(keyname, keyfile):
    if not os.path.isfile(keyfile):
        CONSOLE.info('Keyfile.......... ERROR')
        CONSOLE.error('Did not find local file named %s', keyfile)
        sys.exit(1)

    try:
        region = PNDA_ENV['ec2_access']['AWS_REGION']
        ec2 = boto.ec2.connect_to_region(region)
        stored_key = ec2.get_key_pair(keyname)
        if stored_key is None:
            raise Exception("Key not found %s" % keyname)
        CONSOLE.info('Keyfile.......... OK')
    except:
        CONSOLE.info('Keyfile.......... ERROR')
        CONSOLE.error('Failed to find key %s in ec2.', keyname)
        CONSOLE.error(traceback.format_exc())
        sys.exit(1)


def check_aws_connection():
    region = PNDA_ENV['ec2_access']['AWS_REGION']
    conn = boto.cloudformation.connect_to_region(region)
    if conn is None:
        CONSOLE.info('AWS connection... ERROR')
        CONSOLE.error('Failed to connect to cloud formation API, verify ec2_access settings in "pnda_env.yaml" and try again.')
        sys.exit(1)

    try:
        conn.list_stacks()
        CONSOLE.info('AWS connection... OK')
    except:
        CONSOLE.info('AWS connection... ERROR')
        CONSOLE.error('Failed to query cloud formation API, verify ec2_access settings in "pnda_env.yaml" and try again.')
        CONSOLE.error(traceback.format_exc())
        sys.exit(1)

def check_java_mirror():
    try:
        java_mirror = PNDA_ENV['mirrors']['JAVA_MIRROR']
        response = requests.head(java_mirror)
        response.raise_for_status()
        CONSOLE.info('Java mirror...... OK')
    except KeyError:
        CONSOLE.info('Java mirror...... WARN')
        CONSOLE.warning('Java mirror was not defined in pnda_env.yaml,' +
                        ' provisioning will be more reliable and quicker if you host this in the same AWS availability zone.')
    except:
        CONSOLE.info('Java mirror...... ERROR')
        CONSOLE.error('Failed to connect to java mirror. Verify connection to %s, update config in pnda_env.yaml if required and try again.', '')
        CONSOLE.error(traceback.format_exc())
        sys.exit(1)

def check_package_server():
    try:
        package_uri = '%s/%s' % (PNDA_ENV['pnda_component_packages']['PACKAGES_SERVER_URI'], 'platform/releases/')
        response = requests.head(package_uri)
        if response.status_code != 403 and response.status_code != 200:
            raise Exception("Unexpected status code from %s: %s" % (package_uri, response.status_code))
        CONSOLE.info('Package server... OK')
    except:
        CONSOLE.info('Package server... ERROR')
        CONSOLE.error('Failed to connect to package server. Verify connection to %s, update URL in pnda_env.yaml if required and try again.', package_uri)
        CONSOLE.error(traceback.format_exc())
        sys.exit(1)

def write_pnda_env_sh(cluster):
    client_only = ['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'PLATFORM_GIT_BRANCH']
    with open('cli/pnda_env_%s.sh' % cluster, 'w') as pnda_env_sh_file:
        for section in PNDA_ENV:
            for setting in PNDA_ENV[section]:
                if setting not in client_only:
                    pnda_env_sh_file.write('export %s=%s\n' % (setting, PNDA_ENV[section][setting]))

def write_ssh_config(cluster, bastion_ip, os_user, keyfile):
    with open('cli/ssh_config-%s' % cluster, 'w') as config_file:
        config_file.write('host *\n')
        config_file.write('    User %s\n' % os_user)
        config_file.write('    IdentityFile %s\n' % keyfile)
        config_file.write('    StrictHostKeyChecking no\n')
        config_file.write('    UserKnownHostsFile /dev/null\n')
        config_file.write('    ProxyCommand ssh -i %s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null %s@%s exec nc %%h %%p\n'
                          % (keyfile, os_user, bastion_ip))

    with open('cli/socks_proxy-%s' % cluster, 'w') as config_file:
        config_file.write('eval `ssh-agent`\n')
        config_file.write('ssh-add %s\n' % keyfile)
        config_file.write('ssh -i %s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -A -D 9999 %s@%s\n' % (keyfile, os_user, bastion_ip))

def create(template_data, cluster, flavor, keyname, no_config_check, branch):

    init_runfile(cluster)

    to_runfile({'cmdline':sys.argv,
                'bastion':NODE_CONFIG['bastion-instance'],
                'saltmaster':NODE_CONFIG['salt-master-instance']})

    keyfile = '%s.pem' % keyname

    region = PNDA_ENV['ec2_access']['AWS_REGION']
    cf_parameters = [('keyName', keyname), ('pndaCluster', cluster)]
    for parameter in PNDA_ENV['cloud_formation_parameters']:
        cf_parameters.append((parameter, PNDA_ENV['cloud_formation_parameters'][parameter]))

    if not no_config_check:
        check_aws_connection()
        check_keypair(keyname, keyfile)
        check_package_server()
        check_java_mirror()

    CONSOLE.info('Creating Cloud Formation stack')
    conn = boto.cloudformation.connect_to_region(region)
    stack_status = 'CREATING'
    conn.create_stack(cluster,
                      template_body=template_data,
                      parameters=cf_parameters)

    while stack_status in ['CREATE_IN_PROGRESS', 'CREATING']:
        time.sleep(5)
        CONSOLE.info('Stack is: ' + stack_status)
        stacks = conn.describe_stacks(cluster)
        if len(stacks) > 0:
            stack_status = stacks[0].stack_status

    if stack_status != 'CREATE_COMPLETE':
        CONSOLE.error('Stack did not come up, status is: ' + stack_status)
        sys.exit(1)

    instance_map = get_instance_map(cluster)
    write_ssh_config(cluster, instance_map[cluster + '-' + NODE_CONFIG['bastion-instance']]['ip_address'],
                     PNDA_ENV['ec2_access']['OS_USER'], os.path.abspath(keyfile))
    CONSOLE.debug('The PNDA console will come up on: http://%s', instance_map[cluster + '-' + NODE_CONFIG['console-instance']]['private_ip_address'])

    CONSOLE.info('Bootstrapping saltmaster. Expect this to take a few minutes, check the debug log for progress (%s).', LOG_FILE_NAME)
    saltmaster = instance_map[cluster + '-' + NODE_CONFIG['salt-master-instance']]

    platform_salt_tarball = None
    if 'PLATFORM_SALT_LOCAL' in PNDA_ENV['platform_salt']:
        local_salt_path = PNDA_ENV['platform_salt']['PLATFORM_SALT_LOCAL']
        platform_salt_tarball = '%s.tmp' % str(uuid.uuid1())
        with tarfile.open(platform_salt_tarball, mode='w:gz') as archive:
            archive.add(local_salt_path, arcname='platform-salt', recursive=True)
        scp([platform_salt_tarball], cluster, saltmaster['private_ip_address'])
        os.remove(platform_salt_tarball)

    sm_script = 'bootstrap-scripts/%s/%s.sh' % (flavor, saltmaster['node_type'])
    if not os.path.isfile(sm_script):
        sm_script = 'bootstrap-scripts/%s.sh' % (saltmaster['node_type'])
    scp([sm_script, 'cli/pnda_env_%s.sh' % cluster, 'git.pem'], cluster, saltmaster['private_ip_address'])
    ssh(['source /tmp/pnda_env_%s.sh' % cluster,
         'export PNDA_SALTMASTER_IP=%s' % saltmaster['private_ip_address'],
         'export PNDA_CLUSTER=%s' % cluster,
         'export PNDA_FLAVOR=%s' % flavor,
         'export PLATFORM_GIT_BRANCH=%s' % branch,
         'export PLATFORM_SALT_TARBALL=%s' % platform_salt_tarball if platform_salt_tarball is not None else ':',
         'sudo chmod a+x /tmp/%s.sh' % saltmaster['node_type'],
         '(sudo -E /tmp/%s.sh 2>&1) | tee -a pnda-bootstrap.log; %s' % (saltmaster['node_type'], THROW_BASH_ERROR)],
        cluster, saltmaster['private_ip_address'])

    CONSOLE.info('Bootstrapping other instances. Expect this to take a few minutes, check the debug log for progress (%s).', LOG_FILE_NAME)
    bootstrap_threads = []
    bootstrap_errors = Queue.Queue()
    for key, instance in instance_map.iteritems():
        if '-' + NODE_CONFIG['salt-master-instance'] not in key:
            thread = Thread(target=bootstrap, args=[instance, saltmaster['private_ip_address'], cluster, flavor, branch, bootstrap_errors])
            bootstrap_threads.append(thread)

    for thread in bootstrap_threads:
        thread.start()
        time.sleep(2)

    for thread in bootstrap_threads:
        ret_val = thread.join()

    while not bootstrap_errors.empty():
        ret_val = bootstrap_errors.get()
        raise Exception("Error bootstrapping host, error msg: %s. See debug log (%s) for details." % (ret_val, LOG_FILE_NAME))

    time.sleep(30)
    CONSOLE.info('Running salt to install software. Expect this to take 45 minutes or more, check the debug log for progress (%s).', LOG_FILE_NAME)
    bastion = NODE_CONFIG['bastion-instance']
    ssh(['(sudo salt -v --log-level=debug --timeout=120 --state-output=mixed "*" state.highstate 2>&1) | tee -a pnda-salt.log; %s' % THROW_BASH_ERROR,
         '(sudo CLUSTER=%s salt-run --log-level=debug state.orchestrate orchestrate.pnda 2>&1) | tee -a pnda-salt.log; %s' % (cluster, THROW_BASH_ERROR),
         '(sudo salt "*-%s" state.sls hostsfile 2>&1) | tee -a pnda-salt.log; %s' % (bastion, THROW_BASH_ERROR)],
        cluster, saltmaster['private_ip_address'])
    return instance_map[cluster + '-' + NODE_CONFIG['console-instance']]['private_ip_address']

def expand(template_data, cluster, flavor, old_datanodes, old_kafka, keyname, branch):
    keyfile = '%s.pem' % keyname

    region = PNDA_ENV['ec2_access']['AWS_REGION']
    cf_parameters = [('keyName', keyname), ('pndaCluster', cluster)]
    for parameter in PNDA_ENV['cloud_formation_parameters']:
        cf_parameters.append((parameter, PNDA_ENV['cloud_formation_parameters'][parameter]))

    CONSOLE.info('Updating Cloud Formation stack')
    conn = boto.cloudformation.connect_to_region(region)
    stack_status = 'UPDATING'
    conn.update_stack(cluster,
                      template_body=template_data,
                      parameters=cf_parameters)

    while stack_status in ['UPDATE_IN_PROGRESS', 'UPDATING', 'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS']:
        time.sleep(5)
        CONSOLE.info('Stack is: ' + stack_status)
        stacks = conn.describe_stacks(cluster)
        if len(stacks) > 0:
            stack_status = stacks[0].stack_status

    if stack_status != 'UPDATE_COMPLETE':
        CONSOLE.error('Stack did not come up, status is: ' + stack_status)
        sys.exit(1)

    instance_map = get_instance_map(cluster)
    write_ssh_config(cluster, instance_map[cluster + '-' + NODE_CONFIG['bastion-instance']]['ip_address'],
                     PNDA_ENV['ec2_access']['OS_USER'], os.path.abspath(keyfile))
    saltmaster = instance_map[cluster + '-' + NODE_CONFIG['salt-master-instance']]['private_ip_address']

    CONSOLE.info('Bootstrapping new instances. Expect this to take a few minutes, check the debug log for progress. (%s)', LOG_FILE_NAME)
    bootstrap_threads = []
    for _, instance in instance_map.iteritems():
        if ((instance['node_type'] == 'cdh-dn' and int(instance['node_idx']) >= old_datanodes
             or instance['node_type'] == 'kafka' and int(instance['node_idx']) >= old_kafka)):
            thread = Thread(target=bootstrap, args=[instance, saltmaster, cluster, flavor, branch])
            bootstrap_threads.append(thread)

    for thread in bootstrap_threads:
        thread.start()
        time.sleep(2)

    for thread in bootstrap_threads:
        ret_val = thread.join()
        if ret_val is not None:
            raise Exception("Error bootstrapping host, error msg: %s. See debug log (%s) for details." % (ret_val, LOG_FILE_NAME))

    time.sleep(30)

    CONSOLE.info('Running salt to install software. Expect this to take 10 - 20 minutes, check the debug log for progress. (%s)', LOG_FILE_NAME)
    bastion = NODE_CONFIG['bastion-instance']
    ssh(['(sudo salt -v --log-level=debug --timeout=120 --state-output=mixed "*" state.highstate 2>&1) | tee -a pnda-salt.log; %s' % THROW_BASH_ERROR,
         '(sudo CLUSTER=%s salt-run --log-level=debug state.orchestrate orchestrate.pnda-expand 2>&1) | tee -a pnda-salt.log; %s' % (cluster, THROW_BASH_ERROR),
         '(sudo salt "*-%s" state.sls hostsfile 2>&1) | tee -a pnda-salt.log; %s' % (bastion, THROW_BASH_ERROR)],
        cluster, saltmaster)
    return instance_map[cluster + '-' + NODE_CONFIG['console-instance']]['private_ip_address']

def destroy(cluster):
    CONSOLE.info('Removing ssh access scripts')
    socks_proxy_file = 'cli/socks_proxy-%s' % cluster
    if os.path.exists(socks_proxy_file):
        os.remove(socks_proxy_file)
    ssh_config_file = 'cli/ssh_config-%s' % cluster
    if os.path.exists(ssh_config_file):
        os.remove(ssh_config_file)
    env_sh_file = 'cli/pnda_env_%s.sh' % cluster
    if os.path.exists(env_sh_file):
        os.remove(env_sh_file)
    CONSOLE.info('Deleting Cloud Formation stack')
    region = PNDA_ENV['ec2_access']['AWS_REGION']
    conn = boto.cloudformation.connect_to_region(region)

    stack_status = 'DELETING'
    conn.delete_stack(cluster)
    while stack_status in ['DELETE_IN_PROGRESS', 'DELETING']:
        time.sleep(5)
        CONSOLE.info('Stack is: ' + stack_status)
        try:
            stacks = conn.describe_stacks(cluster)
        except:
            stacks = []

        if len(stacks) > 0:
            stack_status = stacks[0].stack_status
        else:
            stack_status = None

def name_string(value):
    try:
        return re.match(NAME_REGEX, value).group(0)
    except:
        raise argparse.ArgumentTypeError("String '%s' may contain only  a-z 0-9 and '-'" % value)

def get_validation(param_name):
    return VALIDATION_RULES[param_name]

def check_validation(restriction, value):
    if restriction.startswith("<="):
        return value <= int(restriction[2:])

    if restriction.startswith(">="):
        return value > int(restriction[2:])

    if restriction.startswith("<"):
        return value < int(restriction[1:])

    if restriction.startswith(">"):
        return value > int(restriction[1:])

    if "-" in restriction:
        restrict_min = int(restriction.split('-')[0])
        restrict_max = int(restriction.split('-')[1])
        return value >= restrict_min and value <= restrict_max

    return value == int(restriction)

def validate_size(param_name, value):
    restrictions = get_validation(param_name)
    for restriction in restrictions.split(','):
        if check_validation(restriction, value):
            return True
    return False

def node_limit(param_name, value):
    as_num = None
    try:
        as_num = int(value)
    except:
        raise argparse.ArgumentTypeError("'%s' must be an integer, %s found" % (param_name, value))

    if not validate_size(param_name, as_num):
        raise argparse.ArgumentTypeError("'%s' is not in valid range %s" % (as_num, get_validation(param_name)))

    return as_num

def get_args():
    global VALID_FLAVORS
    VALID_FLAVORS = [dir_name for dir_name in os.listdir('../cloud-formation') if  os.path.isdir(os.path.join('../cloud-formation', dir_name))]
    epilog = """examples:
  - create new cluster, prompting for values:
    pnda-cli.py create
  - destroy existing cluster:
    pnda-cli.py destroy -e squirrel-land
  - expand existing cluster:
    pnda-cli.py expand -e squirrel-land -f standard -s keyname -n 10 -k 5
    Either, or both, kafka (k) and datanodes (n) can be changed. The value specifies the new total number of nodes. Shrinking is not supported - this must be done very carefully to avoid data loss.
  - create cluster without user input:
    pnda-cli.py create -s mykeyname -e squirrel-land -f standard -n 5 -o 1 -k 2 -z 3"""
    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter, description='PNDA CLI', epilog=epilog)
    banner()

    parser.add_argument('command', help='Mode of operation', choices=['create', 'expand', 'destroy'])
    parser.add_argument('-e', '--pnda-cluster', type=name_string, help='Namespaced environment for machines in this cluster')
    parser.add_argument('-n', '--datanodes', type=int, help='How many datanodes for the hadoop cluster')
    parser.add_argument('-o', '--opentsdb-nodes', type=int, help='How many Open TSDB nodes for the hadoop cluster')
    parser.add_argument('-k', '--kafka-nodes', type=int, help='How many kafka nodes for the databus cluster')
    parser.add_argument('-z', '--zk-nodes', type=int, help='How many zookeeper nodes for the databus cluster')
    parser.add_argument('-f', '--flavour', help='PNDA flavor: "standard"', choices=VALID_FLAVORS)
    parser.add_argument('-s', '--keyname', help='Keypair name')
    parser.add_argument('-x', '--no-config-check', action='store_true', help='Skip config verifiction checks')
    parser.add_argument('-b', '--branch', help='Branch of platform-salt to use. Overrides value in pnda_env.yaml')

    args = parser.parse_args()
    return args

def main():
    args = get_args()
    print 'Saving debug log to %s' % LOG_FILE_NAME
    pnda_cluster = args.pnda_cluster
    datanodes = args.datanodes
    tsdbnodes = args.opentsdb_nodes
    kafkanodes = args.kafka_nodes
    zknodes = args.zk_nodes
    flavor = args.flavour
    keyname = args.keyname
    no_config_check = args.no_config_check

    if not os.path.basename(os.getcwd()) == "cli":
        print 'Please run from inside the /cli directory'
        sys.exit(1)

    os.chdir('../')

    global PNDA_ENV


    check_config_file()
    with open('pnda_env.yaml', 'r') as infile:
        PNDA_ENV = yaml.load(infile)
        os.environ['AWS_ACCESS_KEY_ID'] = PNDA_ENV['ec2_access']['AWS_ACCESS_KEY_ID']
        os.environ['AWS_SECRET_ACCESS_KEY'] = PNDA_ENV['ec2_access']['AWS_SECRET_ACCESS_KEY']
        print 'Using ec2 credentials:'
        print '  AWS_REGION = %s' % PNDA_ENV['ec2_access']['AWS_REGION']
        print '  AWS_ACCESS_KEY_ID = %s' % PNDA_ENV['ec2_access']['AWS_ACCESS_KEY_ID']
        print '  AWS_SECRET_ACCESS_KEY = %s' % PNDA_ENV['ec2_access']['AWS_SECRET_ACCESS_KEY']

    # read ES cluster setup from yaml
    esMasterNodes = PNDA_ENV['elk-cluster']['MASTER_NODES']
    esDataNodes = PNDA_ENV['elk-cluster']['DATA_NODES']
    esIngestNodes = PNDA_ENV['elk-cluster']['INGEST_NODES']
    esCoordinatorNodes = PNDA_ENV['elk-cluster']['COORDINATING_NODES']
    esMultiNodes = PNDA_ENV['elk-cluster']['MULTI_ROLE_NODES']
    logstashNodes = PNDA_ENV['elk-cluster']['LOGSTASH_NODES']

    # Branch defaults to master
    # but may be overridden by pnda_env.yaml
    # and both of those are overridden by --branch
    branch = 'master'
    if 'PLATFORM_GIT_BRANCH' in PNDA_ENV['platform_salt']:
        branch = PNDA_ENV['platform_salt']['PLATFORM_GIT_BRANCH']
    if args.branch is not None:
        branch = args.branch

    if not os.path.isfile('git.pem'):
        with open('git.pem', 'w') as git_key_file:
            git_key_file.write('If authenticated access to the platform-salt git repository is required then' +
                               ' replace this file with a key that grants access to the git server.\n')

    if args.command == 'destroy':
        if pnda_cluster is not None:
            destroy(pnda_cluster)
            sys.exit(0)
        else:
            print 'destroy command must specify pnda_cluster, e.g.\npnda-cli.py destroy -e squirrel-land'
            sys.exit(1)

    while pnda_cluster is None:
        pnda_cluster = raw_input("Enter a name for the pnda cluster (e.g. squirrel-land): ")
        if not re.match(NAME_REGEX, pnda_cluster):
            print "pnda cluster name may contain only  a-z 0-9 and '-'"
            pnda_cluster = None

    write_pnda_env_sh(pnda_cluster)

    while flavor is None:
        flavor = raw_input("Enter a flavor (%s): " % '/'.join(VALID_FLAVORS))
        if not re.match("^(%s)$" % '|'.join(VALID_FLAVORS), flavor):
            print "Not a valid flavor"
            flavor = None

    while keyname is None:
        keyname = raw_input("Enter a keypair name to use for ssh access to instances: ")

    global VALIDATION_RULES
    validation_file = file('cloud-formation/%s/validation.json' % flavor)
    VALIDATION_RULES = json.load(validation_file)
    validation_file.close()

    global NODE_CONFIG
    node_config_file = file('cloud-formation/%s/config.json' % flavor)
    NODE_CONFIG = json.load(node_config_file)
    node_config_file.close()

    if args.command == 'expand':
        if pnda_cluster is not None:
            node_counts = get_current_node_counts(pnda_cluster)

            if datanodes is None:
                datanodes = node_counts['cdh-dn']
            if kafkanodes is None:
                kafkanodes = node_counts['kafka']

            if not validate_size("datanodes", datanodes):
                print "Consider choice of datanodes again, limits are: %s" % get_validation("datanodes")
                sys.exit(1)
            if not validate_size("kafka-nodes", kafkanodes):
                print "Consider choice of kafkanodes again, limits are: %s" % get_validation("kafka-nodes")
                sys.exit(1)

            if datanodes < node_counts['cdh-dn']:
                print "You cannot shrink the cluster using this CLI, existing number of datanodes is: %s" % node_counts['cdh-dn']
                sys.exit(1)
            elif datanodes > node_counts['cdh-dn']:
                print "Increasing the number of datanodes from %s to %s" % (node_counts['cdh-dn'], datanodes)
            if kafkanodes < node_counts['kafka']:
                print "You cannot shrink the cluster using this CLI, existing number of kafkanodes is: %s" % node_counts['kafka']
                sys.exit(1)
            elif  kafkanodes > node_counts['kafka']:
                print "Increasing the number of kafkanodes from %s to %s" % (node_counts['kafka'], kafkanodes)

            template_data = generate_template_file(flavor, datanodes, node_counts['opentsdb'], kafkanodes, node_counts['zk'],
                                                   esMasterNodes, esIngestNodes, esDataNodes, esCoordinatorNodes,
                                                   esMultiNodes, logstashNodes)
            expand(template_data, pnda_cluster, flavor, node_counts['cdh-dn'], node_counts['kafka'], keyname, branch)
            sys.exit(0)
        else:
            print 'expand command must specify pnda_cluster, e.g.\npnda-cli.py expand -e squirrel-land -f standard -s keyname -n 5'
            sys.exit(1)

    while datanodes is None and get_validation("datanodes") != '0':
        datanodes = raw_input("Enter how many Hadoop data nodes (%s): " % get_validation("datanodes"))
        try:
            datanodes = int(datanodes)
        except:
            print "Not a number"
            datanodes = None

        if not validate_size("datanodes", datanodes):
            print "Consider choice again, limits are: %s" % get_validation("datanodes")
            datanodes = None

    while tsdbnodes is None and get_validation("opentsdb-nodes") != '0':
        tsdbnodes = raw_input("Enter how many Open TSDB nodes (%s): " % get_validation("opentsdb-nodes"))
        try:
            tsdbnodes = int(tsdbnodes)
        except:
            print "Not a number"
            tsdbnodes = None

        if not validate_size("opentsdb-nodes", tsdbnodes):
            print "Consider choice again, limits are: %s" % get_validation("opentsdb-nodes")
            tsdbnodes = None

    while kafkanodes is None and get_validation("kafka-nodes") != '0':
        kafkanodes = raw_input("Enter how many Kafka nodes (%s): " % get_validation("kafka-nodes"))
        try:
            kafkanodes = int(kafkanodes)
        except:
            print "Not a number"
            kafkanodes = None

        if not validate_size("kafka-nodes", kafkanodes):
            print "Consider choice again, limits are: %s" % get_validation("kafka-nodes")
            kafkanodes = None

    while zknodes is None and get_validation("zk-nodes") != '0':
        zknodes = raw_input("Enter how many Zookeeper nodes (%s): " % get_validation("zk-nodes"))
        try:
            zknodes = int(zknodes)
        except:
            print "Not a number"
            zknodes = None

        if not validate_size("zk-nodes", zknodes):
            print "Consider choice again, limits are: %s" % get_validation("zk-nodes")
            zknodes = None

    if datanodes is None:
        datanodes = 0
    if tsdbnodes is None:
        tsdbnodes = 0
    if kafkanodes is None:
        kafkanodes = 0
    if zknodes is None:
        zknodes = 0
    if esMasterNodes is None:
        esMasterNodes = 0
    if esDataNodes is None:
        esDataNodes = 0
    if esIngestNodes is None:
        esIngestNodes = 0
    if esCoordinatorNodes is None:
        esCoordinatorNodes = 0
    if esMultiNodes is None:
        esMultiNodes = 0
    if logstashNodes is None:
        logstashNodes = 0

    node_limit("datanodes", datanodes)
    node_limit("opentsdb-nodes", tsdbnodes)
    node_limit("kafka-nodes", kafkanodes)
    node_limit("zk-nodes", zknodes)
    node_limit("elk-es-master", esMasterNodes)
    node_limit("elk-es-data", esDataNodes)
    node_limit("elk-es-ingest", esIngestNodes)
    node_limit("elk-es-coordinator", esCoordinatorNodes)
    node_limit("elk-es-multi", esMultiNodes)
    node_limit("elk-logstash", logstashNodes)

    template_data = generate_template_file(flavor, datanodes, tsdbnodes, kafkanodes, zknodes,
                                           esMasterNodes, esIngestNodes, esDataNodes, esCoordinatorNodes,
                                           esMultiNodes, logstashNodes)

    console_dns = create(template_data, pnda_cluster, flavor, keyname, no_config_check, branch)
    CONSOLE.info('Use the PNDA console to get started: http://%s', console_dns)
    CONSOLE.info(' Access hints:')
    CONSOLE.info('  - The script ./socks_proxy-%s opens an SSH tunnel to the PNDA cluster listening on a port bound to localhost', pnda_cluster)
    CONSOLE.info('  - Please review ./socks_proxy-%s and ensure it complies with your local security policies before use', pnda_cluster)
    CONSOLE.info('  - Set up a socks proxy with: chmod +x socks_proxy-%s; ./socks_proxy-%s', pnda_cluster, pnda_cluster)
    CONSOLE.info('  - SSH to a node with: ssh -F ssh_config-%s <private_ip>', pnda_cluster)

if __name__ == "__main__":
    try:
        main()
    except Exception as exception:
        CONSOLE.error(exception)
        raise
