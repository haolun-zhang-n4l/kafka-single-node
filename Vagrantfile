# -*- mode: ruby -*-
# vi: set ft=ruby :

# issue of centos 8
# https://github.com/dotless-de/vagrant-vbguest/issues/367#issuecomment-619375784
# https://github.com/dotless-de/vagrant-vbguest/pull/373

vars = {
  'DOCKER_CE_VERSION' => '5:19.03.13~3-0~ubuntu-bionic',
  'DOCKER_COMPOSE_VERSION' => '1.27.4',
  'KAFKA_VERSION' => '1.1.0',
  'KAFKA_HOME' => '$HOME/$KAFKA_NAME'
}

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

Vagrant.configure('2') do |config|
  #config.vm.box = 'ubuntu/focal64'
  config.vm.box = 'ubuntu/bionic64'
  config.vm.box_check_update = false

  config.vm.boot_timeout = 600;

  #config.vm.provision "shell", path: "provision/setup.sh", env: vars, privileged: true

  # always use Vagrants insecure key
  config.ssh.insert_key = false
  config.ssh.username = 'vagrant'

  # vagrant plugin install vagrant-disksize
  #config.disksize.size = '80GB'

  config.vm.synced_folder '.', '/vagrant', disabled: false

  config.vm.define "fastdata" do |fastdata|
    fastdata.vm.hostname = 'fastdata'
    fastdata.vm.network :forwarded_port, guest: 2181, host: 2181 # zookeeper
    fastdata.vm.network :forwarded_port, guest: 9092, host: 9092 # kafka
    fastdata.vm.network :forwarded_port, guest: 8081, host: 8081 # schema-registry
    fastdata.vm.network :forwarded_port, guest: 8082, host: 8082 # kafka-rest
    fastdata.vm.network :forwarded_port, guest: 9021, host: 9021 # control-center

    fastdata.vm.provider 'virtualbox' do |vb|
      if OS.windows?
        # VBoxManage(.exe) setextradata global "VBoxInternal/NEM/UseRing0Runloop" 0
        vb.customize ["setextradata", :id, "VBoxInternal/NEM/UseRing0Runloop", "0"]
      end

      #vb.customize ["modifyvm", :id, "--paravirtprovider", "none"]
      ##vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      ##vb.customize ["modifyvm", :id, "--ioapic", "on"]

      vb.gui = false
      vb.memory = '8192'
      vb.name = 'fastdata'
      vb.cpus = 2
    end

    #fastdata.vm.provision "shell", path: "provision/docker.sh", env: vars, privileged: true
  end

  config.vm.provision "shell", env: vars, privileged: true, inline: <<-SHELL
    apt-get update
    apt-get upgrade -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    apt-get update
    apt-cache policy docker-ce
    apt-get install -y docker-ce=${DOCKER_CE_VERSION}
    systemctl enable docker
    systemctl start docker
    systemctl status docker
    apt-get install -y openssh-server
    systemctl enable ssh
    systemctl start ssh
    systemctl status ssh

    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cd /vagrant

  SHELL
end
