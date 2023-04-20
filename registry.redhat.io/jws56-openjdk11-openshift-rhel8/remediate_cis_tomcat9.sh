#!/bin/bash

# CIS Tomcat9 1.1
rm -rf $JWS_HOME/webapps/ROOT && rm -f $JWS_HOME/webapps/ROOT.war

# CIS Tomcat9 - 4.1, 4.3, 4.4, 4.5, 4.6, 4.7
chmod 770 $JWS_HOME
chmod 770 $JWS_HOME/conf
chmod 770 $JWS_HOME/logs
chmod 770 $JWS_HOME/temp
chmod 770 $JWS_HOME/bin
chmod 770 $JWS_HOME/webapps

# CIS Tomcat9 - 4.8
chmod 660 $JWS_HOME/conf/catalina.properties
# CIS Tomcat9 - 4.9
chmod 660 $JWS_HOME/conf/catalina.policy
# CIS Tomcat9 - 4.10
chmod 660 $JWS_HOME/conf/context.xml
# CIS Tomcat9 - 4.11
chmod 640 $JWS_HOME/conf/logging.properties
# CIS Tomcat9 - 4.12
chmod 660 $JWS_HOME/conf/server.xml
# CIS Tomcat9 - 4.13
chmod 660 $JWS_HOME/conf/tomcat-users.xml
# CIS Tomcat9 - 4.14
chmod 660 $JWS_HOME/conf/web.xml
# CIS Tomcat9 - 4.15
chmod 660 $JWS_HOME/conf/jaspic-providers.xml

# CIS Tomcat9 - 10.6, 10.7, 10.8
chmod 664 $JWS_HOME/bin/launch/catalina.sh && chown 185:root $JWS_HOME/bin/launch/catalina.sh

# CIS Tomcat9 - 10.9, 10.10
chmod 660 $JWS_HOME/conf/server.xml && chown jboss:root $JWS_HOME/conf/server.xml
chmod 664 $JWS_HOME/bin/launch/https.sh && chown 185:root $JWS_HOME/bin/launch/https.sh

# CIS Tomcat9 - 10.12
chmod 660 $JWS_HOME/conf/context.xml && chown 185:root $JWS_HOME/conf/context.xml

# CIS Tomcat9 - 2.1, 2.2, 2.3
# Preventing Server Identification
unzip $JWS_HOME/lib/catalina.jar -d /tmp
cp -f /tmp/ServerInfo.properties /tmp/org/apache/catalina/util/ServerInfo.properties

cd /tmp
zip -r catalina.jar org/ module-info.class META-INF/ 
cp -f /tmp/catalina.jar $JWS_HOME/lib/catalina.jar 
chown 185:root $JWS_HOME/lib/catalina.jar 
chmod 644 $JWS_HOME/lib/catalina.jar

# Cleanup
rm -f /tmp/catalina.jar
rm -rf /tmp/org
rm -f /tmp/module-info.class
rm -rf /tmp/META-INF
rm -f /tmp/ServerInfo.properties