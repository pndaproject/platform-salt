import requests
import socket
import logging
log = logging.getLogger(__name__)

def get_fqdn():
    """ Return FQDN based on getaddrinfo or None otherwise (getfqdn not reliable - bugs.python.org/issue5004) """
    canonname = None
    
    try:
        addr_info = socket.getaddrinfo(socket.gethostname(), None, 0, socket.SOCK_DGRAM, 0, socket.AI_CANONNAME)
        if 0 < len(addr_info):
            family, socktype, proto, canonname, sockaddr = addr_info[0]
    except socket.error:
        pass

    return canonname

def get_name_service():
    """ Returns name service for HA Cluster """
    user_name = hadoop_manager_username()
    password = hadoop_manager_password()
    service = __salt__['pillar.get']('hadoop_services:%s:service' % ("hdfs_namenode"))
    request_url = 'http://%s:7180/api/v11/clusters/%s/services/%s/nameservices' % (hadoop_manager_ip(), cluster_name(), service)
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
    distro = __salt__['grains.get']('hadoop.distro')
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
            namenode_host = name_service
        else:
            namenode_host = get_hosts_by_hadoop_role("hdfs_namenode")[0]
        return 'hdfs://%s:8020' % namenode_host
    else:
        return get_namenode_from_ambari()

def hbase_master_host():
    """Returns host name of an hbase master host"""
    if hadoop_distro() == 'CDH':
        return 'todo'
    else:
        hostname= ambari_request('/clusters/%s/services/HBASE/components/HBASE_MASTER' % (cluster_name()))['host_components'][0]['HostRoles']['host_name']
        return socket.getfqdn(hostname)

def hadoop_manager_ip():
    """ Returns the Cloudera Manager ip address"""
    cm = get_hosts_for_role('hadoop_manager')
    if cm is not None and len(cm) > 0:
        return cm[0]
    else:
        return None

def kafka_brokers_hosts():
    """Returns kafka brokers hosts"""
    return get_hosts_for_role('kafka')

def opentsdb_hosts():
    """Returns opentsdb node hosts"""
    return get_hosts_for_role('opentsdb')

def kafka_zookeepers_hosts():
    """Returns zookeeper hosts"""
    return get_hosts_for_role('zookeeper')

def dns_nameserver_ips():
    """Returns ip addresses of PNDA DNS nameservers"""
    return get_ips_for_role('consul_server')

def get_ips_for_role(role):
    """Returns ip addresses of minions having a specific role"""
    query = "G@pnda_cluster:{} and G@roles:{}".format(cluster_name(), role)
    result = __salt__['mine.get'](query, 'network.ip_addrs', 'compound').values()
    # Only get first ip address
    result = [r[0] for r in result]
    return result if len(result) > 0 else None

def get_hosts_for_role(role):
    """Returns ip addresses of minions having a specific role"""
    query = "G@pnda_cluster:{} and G@roles:{}".format(cluster_name(), role)
    result = __salt__['mine.get'](query, 'network.ip_addrs', 'compound').keys()
    # Add on the domain set in the pillar
    result = [host_name for host_name in result]
    return result if len(result) > 0 else None

def get_hosts_by_hadoop_node(role):
    """Returns ip addresses of minions having a specific role"""
    query = "G@pnda_cluster:{} and G@hadoop:role:{}".format(cluster_name(), role)
    result = __salt__['mine.get'](query, 'network.ip_addrs', 'compound').keys()
    # Add on the domain set in the pillar
    result = [host_name for host_name in result]
    return result if len(result) > 0 else None

def generate_http_link(role, suffix):
    nodes = get_hosts_for_role(role)
    if nodes is not None and len(nodes) > 0:
        return 'http://%s%s' % (nodes[0], suffix)
    else:
        return ''

def generate_external_link(role, suffix):
    cert = __salt__['pillar.get'](role+':cert')
    fqdn = __salt__['pillar.get'](role+':fqdn')
    log.info('generate_external_link: cert=%s' % cert)
    log.info('generate_external_link: fqdn=%s' % fqdn)
    return 'http%s://%s%s' % ('s' if cert else '', fqdn, suffix) if fqdn else ''

def get_gateway_proxy_detail(role):
    gateway = __salt__['pillar.get']('gateway')
    found = None
    for proxy_role, proxy, in gateway.iteritems():
        for topology in proxy['topologies']:
            if role in topology['services']:
                found = {'role':proxy_role,
                         'port':proxy['port'],
                         'base':proxy['base'],
                         'topology':topology['name'],
                         'context':topology['services'][role]['context']}
                break
    assert(found is not None)
    return found

def make_path_from_segments(segments):
    path = ""
    for segment in segments:
        if segment != "": path += "/%s" % segment
    return path

def get_gateway_context_path(role):
    detail = get_gateway_proxy_detail(role)
    return make_path_from_segments([detail['base'], detail['topology'], detail['context']])
    
def get_gateway_link(role):
    detail = get_gateway_proxy_detail(role)
    return generate_external_link(detail['role'], ":%s%s" % (detail['port'], 
                                  make_path_from_segments([detail['base'], detail['topology'], detail['context']])))

def cloudera_get_hosts_by_hadoop_role(service, role_type):
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
    hosts_names = []
    for host_id in hosts_ids:
        request_host_url = 'http://{}/api/v14/hosts/{}'.format(endpoint, host_id)
        r = requests.get(request_host_url, auth=(user, password))
        r.raise_for_status()
        hostname = r.json()['hostname']
        hosts_names.append(hostname)

    return hosts_names

def ambari_get_hosts_by_hadoop_role(service, role_type):
    return [socket.getfqdn(host['HostRoles']['host_name']) for host in ambari_request('/clusters/%s/services/%s/components/%s' % (cluster_name(),service,role_type))['host_components']]

def get_hosts_by_hadoop_role(hadoop_service_name):
    service = __salt__['pillar.get']('hadoop_services:%s:service' % (hadoop_service_name))
    role_type = __salt__['pillar.get']('hadoop_services:%s:component' % (hadoop_service_name))
    if hadoop_distro() == 'CDH':
        return cloudera_get_hosts_by_hadoop_role(service, role_type)
    else:
        return ambari_get_hosts_by_hadoop_role(service, role_type)

def cloudera_get_service_status(service):
    user = hadoop_manager_username()
    password = hadoop_manager_password()
    endpoint = hadoop_manager_ip() + ':7180'
    cluster = cluster_name()

    request_url = 'http://{}/api/v14/clusters/{}/services/{}'.format(endpoint, cluster, service)
    response = requests.get(request_url, auth=(user, password))
    response.raise_for_status()
    service_resp = response.json()

    return service_resp['healthSummary']

def ambari_get_service_status(service):
    user = hadoop_manager_username()
    password = hadoop_manager_password()
    endpoint = hadoop_manager_ip() + ':8080'
    cluster = cluster_name()

    request_url = 'http://{}/api/v1/clusters/{}/services/{}'.format(endpoint, cluster, service)
    response = requests.get(request_url, auth=(user, password))
    response.raise_for_status()
    service_resp = response.json()

    return service_resp['ServiceInfo']['state']
