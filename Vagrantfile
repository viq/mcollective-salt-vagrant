# -*- mode: ruby -*-
# vi: set ft=ruby :

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

Vagrant.configure("2") do |config|
  config.vm.define :middleware do |vmconfig|
    vmconfig.vm.box = "centos_6_3_x86_64"
    vmconfig.vm.network :private_network, ip: "#{SUBNET}.10"
    vmconfig.vm.hostname = "middleware.#{DOMAIN}"
    vmconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", MEMORY]
    end
    vmconfig.vm.box = "centos_6_3_x86_64"
    vmconfig.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.3-x86_64-v20130101.box"

    vmconfig.vm.provision :puppet, :options => ["--pluginsync"], :module_path => "deploy/modules", :facter => { "middleware_ip" => "#{SUBNET}.10" } do |puppet|
      puppet.manifests_path = "deploy"
      puppet.manifest_file = "site.pp"
    end
  end

  INSTANCES.times do |i|
    config.vm.define "node#{i}".to_sym do |vmconfig|
      vmconfig.vm.box = "centos_6_3_x86_64"
      vmconfig.vm.network :private_network, ip: "#{SUBNET}.%d" % (10 + i + 1)
      vmconfig.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", MEMORY]
      end
      vmconfig.vm.hostname = "node%d.#{DOMAIN}" % i
      vmconfig.vm.box = "centos_6_3_x86_64"
      vmconfig.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.3-x86_64-v20130101.box"

      vmconfig.vm.provision :puppet, :options => ["--pluginsync"], :module_path => "deploy/modules", :facter => { "middleware_ip" => "#{SUBNET}.10" } do |puppet|
        puppet.manifests_path = "deploy"
        puppet.manifest_file = "site.pp"
      end
    end
  end
end
