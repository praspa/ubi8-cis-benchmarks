FROM hub-registry-quay-quay-enterprise.apps.hub.test.example.com/cissecure/cis_redhat_ubi8_ubi:8.7-1037.cis0001

# USER root runs the commands after it as the user root
USER root

RUN mkdir -p /run/containers
RUN chmod 775 /run/containers

#defaut kubeconfig
ENV KUBECONFIG=/work/.kube/config

# install stuff
RUN yum -y install hostname httpd-tools wget dos2unix nmap-ncat bind-utils diffutils openldap-clients less curl git nano\
    skopeo java-1.8.0-openjdk-devel unzip vim podman && yum clean all && rm -fR /var/cache/yum 

RUN yum -y install --disableplugin=subscription-manager \
  python3 \
  && yum --disableplugin=subscription-manager clean all

# oc client
RUN curl "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.10.12/openshift-client-linux.tar.gz" -o "openshift-client-linux.tar.gz" \
    && tar xzvf openshift-client-linux.tar.gz && mv oc /usr/local/bin/oc && chmod 755 /usr/local/bin/oc \
    && mv kubectl /usr/local/bin/kubectl && chmod 755 /usr/local/bin/kubectl && rm -f openshift-client-linux.tar.gz

# tkn client
RUN curl -LO https://github.com/tektoncd/cli/releases/download/v0.21.0/tkn_0.21.0_Linux_x86_64.tar.gz \
    && tar xzvf tkn_0.21.0_Linux_x86_64.tar.gz && mv tkn /usr/local/bin/tkn && chmod 755 /usr/local/bin/tkn \
    && rm -f tkn_0.21.0_Linux_x86_64.tar.gz

# Argocd client
RUN curl -L "https://github.com/argoproj/argo-cd/releases/download/v2.2.3/argocd-linux-amd64" -o "argocd" \
    && mv argocd /usr/local/bin/argocd && chmod 755 /usr/local/bin/argocd 

# Argo login script
COPY example/ubi8-devtools/scripts/argocd-login.py /usr/local/bin/argocd-login
RUN chmod 755 /usr/local/bin/argocd-login

# helm
RUN curl https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz -o helm-v3.9.0-linux-amd64.tar.gz \
    && tar xzvf helm-v3.9.0-linux-amd64.tar.gz && mv ./linux-amd64/helm /usr/local/bin/helm \
    && chmod 755 /usr/local/bin/helm && rm -f helm-v3.9.0-linux-amd64.tar.gz

# Cloudctl
RUN curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz \
    && tar xzvf cloudctl-linux-amd64.tar.gz && mv ./cloudctl-linux-amd64 /usr/local/bin/cloudctl \
    && chmod 755 /usr/local/bin/cloudctl && rm -f cloudctl-linux-amd64.tar.gz

RUN mkdir /work && chmod -R 770 /work

# Python
RUN alternatives --set python /usr/bin/python3 && pip3 install pyyaml && pip3 install argparse

# create entrypoint script
RUN echo "#/bin/bash" >> /startup.sh && \
    echo "mkdir -p /work/{scripts,archive,.kube,.ssh}" >> /startup.sh && \
    echo "echo 'alias ll=\"ls -al\"' >> /work/.bashrc" >> /startup.sh && \
    echo "sleep infinity" >> /startup.sh

RUN chmod 770 /startup.sh

# RUN chown 1000 -R .git

# Stop running commands as root
USER 1000

ENV HOME="/work"

WORKDIR /work

ENTRYPOINT ["bash"]
CMD ["/startup.sh"]
