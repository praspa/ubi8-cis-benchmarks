FROM hub-registry-quay-quay-enterprise.apps.hub.test.example.com/ocpv4-stage/cissecure/ubi8/httpd-24:1-209

# Elevate
USER root

# Install packages
RUN yum -y install python3 dos2unix nmap-ncat bind-utils diffutils less curl zip unzip && yum clean all && rm -fR /var/cache/yum 

RUN mkdir -p /opt/benchmark
ADD benchmark/run_benchmark.py /opt/benchmark/run_benchmark.py

#ADD benchmark/httpd-24 /opt/benchmark/httpd-24
RUN chown -R 1001:1001 /opt/benchmark && chmod -R 755 /opt/benchmark

# Add remediation script for apache
#ADD <apache remediate script>.sh

# Perform remediations
#RUN bash <apache remediate script>.sh

# Run CIS Audit at Build Time
#RUN cd /opt/benchmark && python run_benchmark.py -i ./<apache cis checks>.json \
#    -a -s "5.1,6.1,6.5,7.6,9.1,9.3,10.2,10.11,10.19" | tee /opt/benchmark/cis_results.log && \
#    chown 1001:1001 /opt/benchmark/cis_results.log && chmod 444 /opt/benchmark/cis_results.log

# Apache is 48 but not sure it matters yet
# Default User
USER 1001