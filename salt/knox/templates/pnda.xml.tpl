<topology>
    <gateway>
{% if knox_authentication == 'internal' %}
        <provider>
            <role>authentication</role>
                <name>ShiroProvider</name>
                <enabled>true</enabled>
                <param>
                    <name>sessionTimeout</name>
                    <value>30</value>
                </param>
                <param>
                    <name>main.ldapRealm</name>
                    <value>org.apache.hadoop.gateway.shirorealm.KnoxLdapRealm</value>
                </param>
                <param>
                    <name>main.ldapRealm.userDnTemplate</name>
                    <value>uid={0},ou=people,dc=hadoop,dc=apache,dc=org</value>
                </param>
                <param>
                    <name>main.ldapRealm.contextFactory.url</name>
                    <value>ldap://localhost:33389</value>
                </param>
                <param>
                    <name>main.ldapRealm.contextFactory.authenticationMechanism</name>
                    <value>simple</value>
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
        <role>NAMENODE</role>
        <url>hdfs://{{ namenode_host }}:8020</url>
    </service>

    <service>
        <role>JOBTRACKER</role>
        <url>rpc://{{ namenode_host }}:8050</url>
    </service>

    <service>
        <role>WEBHDFS</role>
        <url>http://{{ namenode_host }}:50070/webhdfs</url>
    </service>

    <service>
        <role>WEBHCAT</role>
    </service>

    <service>
        <role>OOZIE</role>
        <url>http://{{ oozie_node }}:11000/oozie</url>
    </service>

    <service>
        <role>WEBHBASE</role>
        <url>http://{{ namenode_host }}:8080</url>
    </service>

    <service>
        <role>HIVE</role>
        <url>http://{{ hive_node }}:10001/cliservice</url>
    </service>

    <service>
        <role>RESOURCEMANAGER</role>
        <url>http://{{ namenode_host }}:8088/ws</url>
    </service>

    <service>
        <role>DRUID-COORDINATOR-UI</role>
        
    </service>

    <service>
        <role>DRUID-COORDINATOR</role>
        
    </service>

    <service>
        <role>DRUID-OVERLORD-UI</role>
        
    </service>

    <service>
        <role>DRUID-OVERLORD</role>
        
    </service>

    <service>
        <role>DRUID-ROUTER</role>
        
    </service>

    <service>
        <role>DRUID-BROKER</role>
        
    </service>

    <service>
        <role>ZEPPELINUI</role>
        
    </service>

    <service>
        <role>ZEPPELINWS</role>
        
    </service>

    <service>
        <role>pnda-deployment-manager</role>
        <url>http://deployment-manager-internal.service.{{ pnda_domain }}:5000</url>
    </service>

</topology>