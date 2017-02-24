import requests

def get_named_service(cm_host, cluster_name, service_name):
    """ Returns named service for HA Cluster """
    user_name = __salt__['pillar.get']('admin_login:user')
    password = __salt__['pillar.get']('admin_login:password')
    request_url = 'http://%s:7180/api/v11/clusters/%s/services/%s/nameservices' % (cm_host,
                                                                                   cluster_name,
                                                                                   service_name)
    r = requests.get(request_url, auth=(user_name, password))
    named_service = ""
    if r.status_code == 200:
        response = r.json()
        if 'items' in response:
            named_service = response['items'][0]['name']
    return named_service


def cluster_name():
    """Returns PNDA cluster name of the minion"""
    cname = __grains__['pnda_cluster']
    return cname

def namenodes_ips():
    """Returns hadoop name nodes ip addresses"""
    cm_name = cluster_name()
    cm_host = cloudera_manager_ip()
    service_name = 'hdfs01'
    named_service = get_named_service(cm_host, cm_name, service_name)
    if named_service:
        return [named_service]
    return ip_addresses('cloudera_namenode')

def cloudera_manager_ip():
    """ Returns the Cloudera Manager ip address"""
    cm = ip_addresses('cloudera_manager')
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
    result = __salt__['mine.get'](query, 'grains.items', 'compound').values()
    if len(result) > 0 and 'ec2' in result[0]:
        result = [r['ec2']['local_ipv4'] for r in result]
        return result

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
    user = __salt__['pillar.get']('admin_login:user')
    password = __salt__['pillar.get']('admin_login:password')
    endpoint = cloudera_manager_ip() + ':7180'
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
