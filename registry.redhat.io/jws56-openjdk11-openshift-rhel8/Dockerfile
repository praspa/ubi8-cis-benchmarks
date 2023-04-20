FROM hub-registry-quay-quay-enterprise.apps.hub.test.example.com/ocpv4-stage/cissecure/jboss-webserver-5/jws56-openjdk11-openshift-rhel8:5.6.2-10

# CIS Tomcat9 - 2.5
ENV JWS_SERVER_NAME=Webserver

# CIS Tomcat9 - 3.1
ENV TOMCAT_SHUTDOWN=ShutItDown

# Elevate
USER root

# Install packages
RUN yum -y install python3 dos2unix nmap-ncat bind-utils diffutils less curl zip unzip && yum clean all && rm -fR /var/cache/yum 

RUN mkdir -p /opt/benchmark
ADD benchmark/run_benchmark.py /opt/benchmark/run_benchmark.py
ADD benchmark/tomcat9 /opt/benchmark/tomcat9
RUN chown -R 1001:1001 /opt/benchmark && chmod -R 755 /opt/benchmark

ADD registry.redhat.io/jws56-openjdk11-openshift-rhel8/remediate_cis_tomcat9.sh /opt/benchmark/remediate_cis_tomcat9.sh

# CIS Tomcat9 - 10.6, 10.7, 10.8
ADD registry.redhat.io/jws56-openjdk11-openshift-rhel8/catalina.sh $JWS_HOME/bin/launch/catalina.sh

# CIS Tomcat9 - 10.9, 10.10
ADD registry.redhat.io/jws56-openjdk11-openshift-rhel8/server.xml $JWS_HOME/conf/server.xml
ADD registry.redhat.io/jws56-openjdk11-openshift-rhel8/https.sh $JWS_HOME/bin/launch/https.sh

# CIS Tomcat9 - 10.12
ADD registry.redhat.io/jws56-openjdk11-openshift-rhel8/context.xml $JWS_HOME/conf/context.xml

# CIS Tomcat9 - 2.1, 2.2, 2.3
# Preventing Server Identification
ADD registry.redhat.io/jws56-openjdk11-openshift-rhel8/conf/org/apache/catalina/util/ServerInfo.properties \
    /tmp/ServerInfo.properties

# Perform remediations
RUN bash /opt/benchmark/remediate_cis_tomcat9.sh

# Run CIS Audit at Build Time
RUN cd /opt/benchmark && python run_benchmark.py -i ./tomcat9/cis_tomcat9.json \
    -a -s "5.1,6.1,6.5,7.6,9.1,9.3,10.2,10.11,10.19" | tee /opt/benchmark/cis_results.log && \
    chown 1001:1001 /opt/benchmark/cis_results.log && chmod 444 /opt/benchmark/cis_results.log

# JWS User
USER 185




