# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  servers=[    
    {
      :hostname => "jenkins",
      :ip => "192.168.100.100",
      :box => "eurolinux-vagrant/centos-stream-9",
      :ram => 1024,
      :port => 80
    },
    {
      :hostname => "centos",
      :ip => "192.168.100.110",
      :box => "eurolinux-vagrant/centos-stream-9",
      :ram => 1024
    }
  ]
  
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the ne documentation at
  # https://docs.vagrantup.com.

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
        node.vm.box = machine[:box]
        node.vm.hostname = machine[:hostname]
        node.vm.network "private_network", ip: machine[:ip]
        if machine[:port]
          node.vm.network "forwarded_port", guest: 8080, host: machine[:port]
        end
        node.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        end
    end
  end
end