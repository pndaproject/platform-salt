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
            <enabled>false</enabled>
        </provider>

        <provider>
            <role>authorization</role>
            <name>AclsAuthz</name>
            <enabled>true</enabled>
        </provider>
{% endif %}
    </gateway>

    <service>
        <role>KAFKA-MANAGER</role>
        <url>http://{{ kafka_manager_host }}:10900</url>
    </service>

    <service>
        <role>KIBANA</role>
        <url>http://{{ kibana_host }}:5601</url>
    </service>

</topology>