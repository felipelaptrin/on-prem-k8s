# Vagrant.configure(2) do |config|
#   config.vm.box = "centos/7"

#   config.vm.provider "qemu" do |qe|
#     qe.arch = "x86_64"
#     qe.machine = "q35"
#     qe.cpu = "qemu64"
#     qe.memory = "1G"
#     qe.net_device = "virtio-net-pci"
#   end

#   config.vm.define "rancher" do |rancher|
#   end

#   config.vm.define "node1" do |node1|
#   end
# end


# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (always use the latest).

Vagrant.configure("2") do |config|
  # Set the base box
  config.vm.box = "ubuntu/bionic64" # Update to "ubuntu/jammy64" for Ubuntu 22.04

  # Customize the amount of memory on the VM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end

  config.vm.network "private_network", type: "dhcp"
  # Sync folder from host to guest
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.hostname = "ubuntu-vm"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "ubuntu-vm"
  end
end
