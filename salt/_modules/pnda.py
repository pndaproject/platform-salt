import requests

def get_name_service():
    """ Returns name service for HA Cluster """
    user_name = hadoop_manager_username()
    password = hadoop_manager_password()
    request_url = 'http://%s:7180/api/v11/clusters/%s/services/%s/nameservices' % (hadoop_manager_ip(), cluster_name(), 'hdfs01')
    r = requests.get(request_url, auth=(user_name, password))
    name_service = ""
    if r.status_code == 200:
        response = r.json()
        if 'items' in response:
            name_service = response['items'][0]['name']
    return name_service


def cluster_name():
    """Returns PNDA cluster name of the minion"""
    cname = __grains__['pnda_cluster']
    return cname

def hadoop_manager_username():
    """Returns username to log into the hadoop cluster manager"""
    uname = __salt__['pillar.get']('admin_login:user')
    return uname

def hadoop_manager_password():
    """Returns password to log into the hadoop cluster manager"""
    pwrd = __salt__['pillar.get']('admin_login:password')
    return pwrd

def hadoop_distro():
    """Returns hadoop distro"""
    distro = __salt__['pillar.get']('hadoop.distro')
    return distro

def ambari_request(uri):
    full_uri = 'http://%s:8080/api/v1%s' % (hadoop_manager_ip(), uri)
    headers = {'X-Requested-By': hadoop_manager_username()}
    auth = (hadoop_manager_username(), hadoop_manager_password())
    return requests.get(full_uri, auth=auth, headers=headers).json()

def get_namenode_from_ambari():
    """Returns hadoop namenode IP address"""
    core_site = ambari_request('/clusters/%s?fields=Clusters/desired_configs/core-site' % cluster_name())
    config_version = core_site['Clusters']['desired_configs']['core-site']['tag']
    core_site_config = ambari_request('/clusters/%s/configurations/?type=core-site&tag=%s' % (cluster_name(), config_version))
    return core_site_config['items'][0]['properties']['fs.defaultFS']

def hadoop_namenode():
    """Returns the hadoop namenode host or nameservice name in case of HA namenode"""
    if hadoop_distro() == 'CDH':
        namenode_host = None
        name_service = get_name_service()
        if name_service:
            namenode_host = [name_service]
        else:
            namenode_host = cloudera_get_hosts_by_role('hdfs01', 'NAMENODE')[0]
        return 'hdfs://%s:8020' % namenode_host
    else:
        return get_namenode_from_ambari()

def hbase_master_host():
    """Returns host name of an hbase master host"""
    if hadoop_distro() == 'CDH':
        return 'todo'
    else:
        return ambari_request('/clusters/%s/services/HBASE/components/HBASE_MASTER' % (cluster_name()))['host_components'][0]['HostRoles']['host_name']

def hadoop_manager_ip():
    """ Returns the Cloudera Manager ip address"""
    cm = ip_addresses('hadoop_manager')
    if cm is not None and len(cm) > 0:
        return cm[0]
    else:
        return None

def kafka_brokers_ips():
    """Returns kafka brokers ip addresses"""
    return ip_addresses('kafka')

def kafka_zookeepers_ips():
    """Returns zookeeper ip addresses"""
    return ip_addresses('zookeeper')

def ldap_ip():
    """Returns the ip address of the LDAP server"""
    query = "G@roles:LDAP"
    result = __salt__['mine.get'](query, 'network.ip_addrs', 'compound').values()
    # Only get first ip address
    return result[0][0] if len(result) > 0 else None

def ip_addresses(role):
    """Returns ip addresses of minions having a specific role"""
    query = "G@pnda_cluster:{} and G@roles:{}".format(cluster_name(), role)
    result = __salt__['mine.get'](query, 'network.ip_addrs', 'compound').values()
    # Only get first ip address
    result = [r[0] for r in result]
    return result if len(result) > 0 else None

def generate_http_link(role, suffix):
    nodes = ip_addresses(role)
    if nodes is not None and len(nodes) > 0:
        return 'http://%s%s' % (nodes[0], suffix)
    else:
        return ''

def cloudera_get_hosts_by_role(service, role_type):
    user = hadoop_manager_username()
    password = hadoop_manager_password()
    endpoint = hadoop_manager_ip() + ':7180'
    cluster = cluster_name()

    request_url = 'http://{}/api/v14/clusters/{}/services/{}/roles'.format(endpoint, cluster, service)
    r = requests.get(request_url, auth=(user, password))
    r.raise_for_status()
    roles = r.json()

    # Filter hosts with the right role type
    hosts_ids = [item['hostRef']['hostId'] for item in roles['items'] if item['type'] == role_type]

    # Get ip addresses
    hosts_ips = []
    for host_id in hosts_ids:
        request_host_url = 'http://{}/api/v14/hosts/{}'.format(endpoint, host_id)
        r = requests.get(request_host_url, auth=(user, password))
        r.raise_for_status()
        ip_address = r.json()['ipAddress']
        hosts_ips.append(ip_address)

    return hosts_ips

def ambari_get_hosts_by_role(service, role_type):
    return [host['HostRoles']['host_name'] for host in ambari_request('/clusters/%s/services/%s/components/%s' % (cluster_name(),service,role_type))['host_components']]

def get_hosts_by_role(service, role_type):
    if hadoop_distro() == 'CDH':
        return cloudera_get_hosts_by_role(service, role_type)
    else:
        return ambari_get_hosts_by_role(service, role_type)