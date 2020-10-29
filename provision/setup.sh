#!/bin/bash -eux

# Add vagrant user to sudoers.
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
echo "ubuntu         ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s#%sudo  ALL=(ALL:ALL) ALL#%sudo ALL=(ALL) NOPASSWD: ALL#" /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

rm -rf /var/lib/apt/lists/*
apt-get -yq clean
apt-get -yq update --fix-missing
apt-get -yq upgrade
apt-get -yq install git wget curl vim openssh-server rsync xinetd policykit-1 \
    apt-transport-https aria2 ca-certificates gnupg2 \
    id-utils net-tools software-properties-common unzip
