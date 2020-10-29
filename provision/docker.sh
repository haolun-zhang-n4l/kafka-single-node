#!/bin/bash -eux

ARIA2C_DOWNLOAD="aria2c --file-allocation=none -c -x 10 -s 10 -m 0 --console-log-level=notice --log-level=notice --summary-interval=0"

pwd
ls -ahl
curl -sSL https://get.docker.com | bash
service docker start
if [ ! -f /home/vagrant/.docker/config.json ]; then mkdir -p /home/vagrant/.docker; touch /home/vagrant/.docker/config.json; echo '{}' > /home/vagrant/.docker/config.json; fi
chown root:vagrant /var/run/docker.sock
chmod 660 /var/run/docker.sock
usermod -a -G docker vagrant || echo "useradd: user 'vagrant' already exists"

sed -i "s#ExecStart=/usr/bin/dockerd -H fd://#ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375#" /lib/systemd/system/docker.service
echo 'export DOCKER_HOST="tcp://127.0.0.1:2375"' | tee -a /root/.profile
echo 'export DOCKER_HOST="tcp://127.0.0.1:2375"' | tee -a /home/vagrant/.profile

# Docker Compose
${ARIA2C_DOWNLOAD} -d /usr/local/bin -o docker-compose https://github.com/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m`
chown root:vagrant /usr/local/bin/docker-compose
chmod 775 /usr/local/bin/docker-compose

# AWS ECR
#apt -yq upgrade python3
#apt -yq install python3-pip
#pip3 install awscli --upgrade --user
#cp -r /root/.local /home/vagrant/ && chown -R vagrant:vagrant /home/vagrant/.local
#if [ -f ~/.aws/config ] && [ -f ~/.aws/credentials ]; then eval $(aws ecr get-login --region $(cat ~/.aws/config | grep region | awk -F= '{print $2}') --no-include-email); fi

#docker run -it --rm \
#  --name swarmpit-installer \
#  --volume /var/run/docker.sock:/var/run/docker.sock \
#  swarmpit/install:1.7
