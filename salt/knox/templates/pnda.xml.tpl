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
        <role>HIVE</role>
        <url>http://{{ hive_host }}:10001/cliservice</url>
    </service>

    <service>
        <role>YARN</role>
        <url>http://{{ yarn_rm_host }}:8088</url>
    </service>

    <service>
        <role>YARNUI</role>
        <url>http://{{ yarn_rm_host }}:8088</url>
    </service>
    
    <service>
        <role>JOBHISTORYUI</role>
        <url>http://{{ mr2_history_server_host }}:19888</url>
    </service>

    <service>
        <role>SPARKHISTORYUI</role>
        <url>http://{{ spark_history_server_host }}:18080</url>
    </service>

    <service>
        <role>pnda-deployment-manager</role>
        <url>http://deployment-manager-internal.service.{{ pnda_domain }}:5000</url>
    </service>

    <service>
        <role>pnda-package-repository</role>
        <url>http://package-repository-internal.service.{{ pnda_domain }}:8888</url>
    </service>

    <service>
        <role>opentsdb</role>
        <url>http://opentsdb-internal.service.{{ pnda_domain }}:{{ opentsdb_port }}</url>
    </service>

    <service>
        <role>PNDA-CONSOLE</role>
        <url>http://console-internal.service.{{ pnda_domain }}</url>
    </service>

</topology>
