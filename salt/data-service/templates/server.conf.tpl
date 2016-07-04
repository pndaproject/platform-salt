{%- set cm_node = [] %}
{%- set pnda_cluster = salt['pnda.cluster_name']() %}
{%- for server, addrs in salt['mine.get']("G@pnda_cluster:"+pnda_cluster+" and G@roles:cloudera_manager", 'network.ip_addrs', expr_form='compound').items() %}
{%- do cm_node.append(addrs[0]) %}
{%- endfor %}
{%- set cm_node_ip = cm_node|join(" ") %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}
ports = [7000, 7001]
bind_address = '0.0.0.0'
sync_period = 5000
datasets_table = "platform_datasets"
data_repo = "{{ location }}"
cm_host = "{{ cm_node_ip }}"
cm_user = "{{ cm_username }}"
cm_pass = "{{ cm_password }}"
log_file_prefix = "log"
