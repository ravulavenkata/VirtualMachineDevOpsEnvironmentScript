#!/bin/bash
set -x

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

TERRAFORM_VERSION="0.11.7"

# create new ssh key
[[ ! -f /home/ubuntu/.ssh/mykey ]] \
&& mkdir -p /home/ubuntu/.ssh \
&& ssh-keygen -f /home/ubuntu/.ssh/mykey -N '' \
&& chown -R ubuntu:ubuntu /home/ubuntu/.ssh


# install packages

#install yum
apt-get -y install yum

if [ ${REDHAT_BASED} ] ; then
  yum -y update
  yum install -y docker ansible unzip wget
else 
  apt-get update
  apt-get -y install docker.io ansible unzip
fi
# add docker privileges
usermod -G docker ubuntu

# install pip
pip install -U pip && pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi

# install awscli and ebcli
pip install -U awscli

pip install -U awsebcli

#install c++ make
apt-get -y install g++ make

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get -y install nodejs

sudo npm install npm --global


#terraform

T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip


# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi
