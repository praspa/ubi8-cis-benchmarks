FROM hub-registry-quay-quay-enterprise.apps.hub.test.example.com/ocpv4-stage/cissecure/ubi8/nodejs-16:1-72

# Elevate
USER root

# Install packages
RUN yum -y install python3 dos2unix nmap-ncat bind-utils diffutils less curl zip unzip && yum clean all && rm -fR /var/cache/yum 

RUN mkdir -p /opt/benchmark
ADD benchmark/run_benchmark.py /opt/benchmark/run_benchmark.py

#ADD benchmark/nodejs /opt/benchmark/nodejs
RUN chown -R 1001:1001 /opt/benchmark && chmod -R 755 /opt/benchmark

# Add remediation script for node
#ADD <node remediate script>.sh

# Perform remediations
#RUN bash <node remediate script>.sh

# Run CIS Audit at Build Time
#RUN cd /opt/benchmark && python run_benchmark.py -i ./<node cis checks>.json \
#    -a -s "5.1,6.1,6.5,7.6,9.1,9.3,10.2,10.11,10.19" | tee /opt/benchmark/cis_results.log && \
#    chown 1001:1001 /opt/benchmark/cis_results.log && chmod 444 /opt/benchmark/cis_results.log

# Default Node User
USER 1001
