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
        <role>pnda-deployment-manager</role>
        <url>http://deployment-manager-internal.service.{{ pnda_domain }}:5000</url>
    </service>

    <service>
        <role>pnda-package-repository</role>
        <url>http://package-repository-internal.service.{{ pnda_domain }}:8888</url>
    </service>

    <service>
        <role>YARN</role>
        <url>http://{{ yarn_rm_host }}:8088</url>
    </service>

    <service>
        <role>YARNUI</role>
        <url>http://{{ yarn_rm_host }}:8088</url>
    </service>

</topology>