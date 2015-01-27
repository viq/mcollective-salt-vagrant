# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'vagrant-hostmanager'

# apart from the middleware node, create
# this many nodes in addition to the middleware
INSTANCES=5

# the nodes will be called middleware.example.net
# and node0.example.net, you can change this here
DOMAIN="example.net"

# these nodes do not need a lot of RAM, 384 is
# is enough but you can tweak that here
MEMORY=384

# the instances is a hostonly network, this will
# be the prefix to the subnet they use
SUBNET="192.168.2"

$set_puppet_version = <<EOF
/bin/rpm -Uvh http://yum.puppetlabs.com/el/6x/products/x86_64/puppetlabs-release-6-10.noarch.rpm
/usr/bin/yum clean all
/usr/bin/yum makecache
/usr/bin/yum -y erase puppet
/usr/bin/yum -y install puppet
EOF

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.vm.define :middleware do |vmconfig|
    vmconfig.vm.network :private_network, ip: "#{SUBNET}.10"
    vmconfig.vm.hostname = "middleware"
    vmconfig.hostmanager.aliases = "salt"
    vmconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", MEMORY]
    end
    vmconfig.vm.box = "centos_6_5_x86_64"
    vmconfig.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.5-x86_64-v20140504.box"
    vmconfig.vm.provision :hostmanager
    vmconfig.vm.provision :shell, :inline => $set_puppet_version
    vmconfig.vm.provision :puppet, :options => ["--pluginsync --hiera_config /vagrant/deploy/hiera.yaml"], :module_path => "deploy/modules", :facter => { "middleware_ip" => "#{SUBNET}.10" } do |puppet|
      puppet.manifests_path = "deploy"
      puppet.manifest_file = "site.pp"
    end
    vmconfig.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.install_master = true
      salt.always_install = false
      salt.master_key = "deploy/salt_keys/master.pem"
      salt.master_pub = "deploy/salt_keys/master.pub"
      salt.minion_key = "deploy/salt_keys/minion.pem"
      salt.minion_pub = "deploy/salt_keys/minion.pub"
      salt.seed_master = { middleware: salt.minion_pub, node0: salt.minion_pub, node1: salt.minion_pub, node2: salt.minion_pub, node3: salt.minion_pub, node4: salt.minion_pub }
      salt.temp_config_dir = "/tmp"
      salt.run_highstate = true
    end
  end

  INSTANCES.times do |i|
    config.vm.define "node#{i}".to_sym do |vmconfig|
      vmconfig.vm.network :private_network, ip: "#{SUBNET}.%d" % (10 + i + 1)
      vmconfig.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", MEMORY]
      end
      vmconfig.vm.hostname = "node%d" % i
      vmconfig.vm.box = "centos_6_5_x86_64"
      vmconfig.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.5-x86_64-v20140504.box"
      vmconfig.vm.provision :hostmanager
      vmconfig.vm.provision :puppet, :options => ["--pluginsync --hiera_config /vagrant/deploy/hiera.yaml"], :module_path => "deploy/modules", :facter => { "middleware_ip" => "#{SUBNET}.10" } do |puppet|
        puppet.manifests_path = "deploy"
        puppet.manifest_file = "site.pp"
      end
      vmconfig.vm.provision :salt do |salt|
        salt.install_type = "stable"
        salt.always_install = false
        salt.minion_key = "deploy/salt_keys/minion.pem"
        salt.minion_pub = "deploy/salt_keys/minion.pub"
      end
    end
  end
end
