from cm_api.api_client import ApiResource


def connect_cm(cm_api, cm_username, cm_password):
    api = ApiResource(cm_api, username=cm_username, password=cm_password)
    return api

def zookeeper_quorum():
    """ Return list of ZK quorum """
    user_name = __salt__['pillar.get']('admin_login:user')
    password = __salt__['pillar.get']('admin_login:password')
    cm_ip = __salt__['pnda.cloudera_manager_ip']()
    api = connect_cm(
        cm_ip,
        user_name,
        password)
    cluster_name = api.get_all_clusters()[0].name
    cluster = api.get_cluster(cluster_name)
    zk_quorum = []
    for service in cluster.get_all_services():
        if service.type == "ZOOKEEPER":
            for role in service.get_all_roles():
                if role.type == "SERVER":
                    zk_quorum.append('%s' % api.get_host(role.hostRef.hostId).ipAddress + ':2181')
    return ",".join(zk_quorum)


