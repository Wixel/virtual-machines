# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  # config.ssh.insert_key = false
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end
  config.vm.provision "shell", inline: <<-SHELL

  SHELL
end
