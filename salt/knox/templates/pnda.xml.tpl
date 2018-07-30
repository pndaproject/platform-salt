<topology>
    <gateway>
{% if knox_authentication == 'pam' %}
        <provider>
            <role>authentication</role> 
            <name>ShiroProvider</name> 
            <enabled>true</enabled> 
            <param> 
                <name>sessionTimeout</name> 
                <value>30</value>
            </param>                                              
            <param>
                <name>main.pamRealm</name> 
                <value>org.apache.hadoop.gateway.shirorealm.KnoxPamRealm</value>
            </param> 
            <param>                                                    
               <name>main.pamRealm.service</name> 
               <value>login</value> 
            </param>
            <param>                                                    
               <name>urls./**</name> 
               <value>authcBasic</value> 
            </param>
        </provider>

        <provider>
            <role>identity-assertion</role>
            <name>Default</name>
            <enabled>true</enabled>
        </provider>

        <provider>
            <role>authorization</role>
            <name>AclsAuthz</name>
            <enabled>true</enabled>
        </provider>
{% endif %}
{% if ha_enabled %}
        <provider>
            <role>ha</role>
            <name>HaProvider</name>
            <enabled>true</enabled>
            <param>
               <name>YARNUI</name>
               <value>maxFailoverAttempts=3;failoverSleep=1000;enabled=true</value>
            </param>
        </provider>
{% endif %}
    </gateway>
    <service>
        <role>WEBHDFS</role>
        <url>http://{{ webhdfs_host }}:14000/webhdfs</url>
    </service>

    <service>
        <role>WEBHBASE</role>
        <url>http://{{ hbase_rest_host }}:20550</url>
    </service>

    <service>
        <role>HBASEUI</role>
        <url>http://{{ hbase_rest_host }}:16010</url>
    </service>

    <service>
        <role>HIVE</role>
        <url>http://{{ hive_host }}:{{ hive_port }}/cliservice</url>
    </service>

    <service>
        <role>YARN</role>
        {% for item in yarn_rm_hosts %}
            <url>http://{{ item }}:8088</url>
        {% endfor %}
    </service>

    <service>
        <role>YARNUI</role>
        {% for item in yarn_rm_hosts %}
            <url>http://{{ item }}:8088</url>
        {% endfor %}
    </service>
    
    <service>
        <role>JOBHISTORYUI</role>
        <url>http://{{ mr2_history_server_host }}:19888</url>
    </service>

    <service>
        <role>SPARKHISTORYUI</role>
        <url>http://{{ spark_history_server_host }}:{{ spark_history_server_port }}</url>
    </service>

    <service>
        <role>PNDA-DEPLOYMENT-MANAGER</role>
        <url>http://deployment-manager-internal.service.{{ pnda_domain }}:5000</url>
    </service>

    <service>
        <role>PNDA-PACKAGE-REPOSITORY</role>
        <url>http://package-repository-internal.service.{{ pnda_domain }}:8888</url>
    </service>

    <service>
        <role>OPENTSDB</role>
        <url>http://opentsdb-internal.service.{{ pnda_domain }}:{{ opentsdb_port }}</url>
    </service>

    <service>
        <role>PNDA-CONSOLE</role>
        <url>http://console-internal.service.{{ pnda_domain }}</url>
    </service>

    
{% if hadoop_distro == 'HDP' %}

    <service>
        <role>SPARK2HISTORYUI</role>
        <url>http://{{ spark2_history_server_host }}:18081</url>
    </service>

    <service>
        <role>AMBARI</role>
        <url>http://{{ ambari_server_host }}:8080</url>
    </service>

    <service>
        <role>AMBARIUI</role>
        <url>http://{{ ambari_server_host }}:8080</url>
    </service>

{% endif %}

    <service>
        <role>FLINKHISTORYUI</role>
        <url>http://{{ flink_history_server_host }}:{{ flink_history_server_port }}</url>
    </service>

    <service>
        <role>HDFSUI</role>
        <url>http://{{ webhdfs_host }}:50070</url>
    </service>

</topology>
