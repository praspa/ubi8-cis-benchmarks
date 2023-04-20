FROM hub-registry-quay-quay-enterprise.apps.hub.test.example.com/ocpv4-stage/cissecure/ubi8/ubi:8.7-1037

USER root

RUN yum -y install python3 dos2unix nmap-ncat bind-utils diffutils less curl zip unzip && yum clean all && rm -fR /var/cache/yum

RUN mkdir -p /opt/benchmark

COPY benchmark/run_benchmark.py /opt/benchmark/
COPY benchmark/ubi8/ /opt/benchmark/

COPY registry.redhat.io/ubi8/remediate_cis_rhel8.sh /opt/benchmark/remediate_cis_rhel8.sh

# 1.8.1.1, 1.8.1.2, 1.8.1.3
# Fix warning banners
COPY registry.redhat.io/ubi8/etc/issue /etc/issue
COPY registry.redhat.io/ubi8/etc/issue.net /etc/issue.net
COPY registry.redhat.io/ubi8/etc/motd /etc/motd

# 5.4.1
COPY registry.redhat.io/ubi8/etc/security/pwquality.conf /etc/security/pwquality.conf

# 5.4.2, 5.4.3
COPY registry.redhat.io/ubi8/etc/pam.d/password-auth /etc/pam.d/password-auth
COPY registry.redhat.io/ubi8/etc/pam.d/system-auth /etc/pam.d/system-auth

# 5.5.1.1, 5.5.1.2
COPY registry.redhat.io/ubi8/etc/login.defs /etc/login.defs

# 5.5.3
COPY registry.redhat.io/ubi8/etc/profile.d/shell-timeout.sh /etc/profile.d/shell-timeout.sh

# 5.7
COPY registry.redhat.io/ubi8/etc/pam.d/su /etc/pam.d/su

# Bulk Remediation based on known findings
RUN bash /opt/benchmark/remediate_cis_rhel8.sh

# CIS RHEL8 Audit the image
# see cis_ubi8_notes.txt for discussion
RUN set -o pipefail && cd /opt/benchmark && python3 run_benchmark.py -i ./cis_rhel8.json -a \
    -s "1.1.2,1.1.3,1.1.4,1.1.5,1.1.6,1.1.7,1.1.8,1.1.9,1.1.10,1.1.11,1.1.12,1.1.13,1.1.14,1.2.1,1.11,2.2.1.1,4.1.1.1,6.1.12,3.1.2,3.2.2,3.2.3,3.2.4,3.2.9,3.6,5.5.5" \
    | tee /opt/benchmark/cis_rhel8_results.log

RUN chown 1001:1001 /opt/benchmark/cis_rhel8_results.log && chmod 444 /opt/benchmark/cis_rhel8_results.log

# Drop to default user
USER 1001
