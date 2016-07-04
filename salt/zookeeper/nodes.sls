{%- set selector = 'G@pnda_cluster:' + salt['grains.get']('pnda_cluster') + ' and G@roles:zookeeper' %}
{%- set cluster_grains = salt['mine.get'](selector, 'network.ip_addrs', 'compound') %}

{%- set c = cycler(*range(1, 255)) %}
{%- for server, addrs in cluster_grains.items() %}
{%- do nodes.append({'id': c.next(), 'ip': addrs[0] , 'fqdn': server }) %}
{%- endfor %}
