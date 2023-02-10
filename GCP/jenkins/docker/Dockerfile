FROM openjdk:8-jdk-stretch

## Install required packages for Packer, Ansible and  Install git lfs on Debian stretch per https://github.com/git-lfs/git-lfs/wiki/Installation#debian-and-ubuntu
# Avoid JENKINS-59569 - git LFS 2.7.1 fails clone with reference repository
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y git \
  curl \
  jq \
  unzip \
  build-essential \
  openssh-client \
  libssl-dev \
  libffi-dev \
  libyaml-dev \
  python3 \
  python3-setuptools \
  python3-pip \
  python3-dev && \
  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
  apt-get install -y git-lfs && \
  git lfs install && \
  pip3 install awscli --upgrade && \
  rm -rf /var/lib/apt/lists/*

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.16.1
COPY tini_pub.gpg ${JENKINS_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
  && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
  && gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg \
  && gpg --verify /sbin/tini.asc \
  && rm -rf /sbin/tini.asc /root/.gnupg \
  && chmod +x /sbin/tini

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.204.1}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=12b9ebbf9eb1cd1deab0d11512511bcd80a5d3a754dffab54dd6385d788d5284

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY tini-shim.sh /bin/tini
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup ${REF}/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

##################
## Packer Tools ##
##################

ENV ANSIBLE_ROLES_PATH /srv/ansible/roles

USER root
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
  pip3 install -U wheel && \
  pip3 install -U virtualenv \
  molecule \
  ansible==2.7.10

# Download and deploy packer
ENV PACKER_URI=https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_linux_amd64.zip
ENV PACKER_ARCHIVE=/tmp/packer_1.4.5_linux_amd64.zip

RUN curl $PACKER_URI -o $PACKER_ARCHIVE && \
  unzip $PACKER_ARCHIVE -d /usr/local/bin/

# Prepare Ansible environment
RUN mkdir -p $ANSIBLE_ROLES_PATH && \
  mkdir -p /mnt/config && \
  mkdir -p $HOME && \
  mkdir -p /usr/share/ansible/plugins/connection && \
  mkdir -p /mnt/secrets \
  mkdir -p $JENKINS_HOME/.ssh \
  mkdir -p $JENKINS_HOME/.aws

COPY ./files/packer-tools/packer.py /usr/share/ansible/plugins/connection/packer.py
COPY ./files/packer-tools/ssh-wrapper.sh /usr/local/bin/ssh-wrapper.sh
COPY ./files/packer-tools/provisioners/ansible/ansible-wrapper.sh /usr/local/bin/ansible-wrapper.sh
COPY ./files/packer-tools/provisioners/ansible/ansible-galaxy-wrapper.sh /usr/local/bin/ansible-galaxy-wrapper.sh

# copy needed credentials
COPY ./files/.ssh/config $JENKINS_HOME/.ssh/config
COPY ./files/.aws/config $JENKINS_HOME/.aws/config
COPY ./files/packer-tools/rsa_key.pem /mnt/secrets/git.pem
COPY ./files/packer-tools/smartvault-staging-us-east-2.pem /mnt/secrets/ssh-stg.pem
COPY ./files/packer-tools/smartvault-production-us-east-2.pem /mnt/secrets/ssh-prd.pem

# change file permissions
RUN chmod 666 /mnt/secrets/git.pem && \
  chmod 666 /mnt/secrets/ssh-stg.pem && \
  chmod 666 /mnt/secrets/ssh-prd.pem && \
  chmod 777 -R $ANSIBLE_ROLES_PATH

USER ${user}

ENV SSH_PRIV_KEY_FILE_stg=/mnt/secrets/ssh-stg.pem
ENV SSH_PRIV_KEY_FILE_prd=/mnt/secrets/ssh-prd.pem
ENV GIT_SSH=ssh-wrapper.sh
ENV GIT_SSH_COMMAND=ssh-wrapper.sh
ENV GIT_KEY=/mnt/secrets/git.pem


#####################
## Terraform Tools ##
#####################

ARG TERRAFORM_VERSION=0.12.20

# Download and deploy terraform
USER root

ENV TERRAFORM_URI=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV TERRAFORM_ARCHIVE=/tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl $TERRAFORM_URI -o $TERRAFORM_ARCHIVE && \
  unzip $TERRAFORM_ARCHIVE -d /usr/local/bin/

# Prepare Terraform environment
RUN mkdir -p /mnt/config/terraform

# Copy bash tools
COPY ./files/terraform/bin/tfprovision.sh /usr/local/bin/tfprovision.sh
COPY ./files/terraform/bin/tfplan.sh /usr/local/bin/tfplan.sh
COPY ./files/terraform/bin/tfdestroy.sh /usr/local/bin/tfdestroy.sh
COPY ./files/terraform/lib/tflib.sh /usr/local/bin/tflib.sh

# Copy standard terraform backend file
COPY ./files/packer-tools/backend.tfvars.json /mnt/config/terraform/backend.tfvars.json


# change file permissions
RUN chmod 777 -R /mnt/config/terraform

USER ${user}