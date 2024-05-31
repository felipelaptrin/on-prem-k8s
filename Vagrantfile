Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Base configuration for all VMs
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 1
    # Enable time synchronization
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
  end

  # Network configuration: Using a private network with DHCP
  config.vm.network "private_network", type: "dhcp"

  # Define Rancher VM
  config.vm.define "rancher" do |rancher|
    rancher.vm.hostname = "rancher"
    rancher.vm.network "private_network", type: "dhcp"
    rancher.vm.provider "virtualbox" do |vb|
      vb.name = "rancher"
      vb.memory = "4096"
    end
  end

  # Define Node1 VM
  config.vm.define "node1" do |node1|
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", type: "dhcp"
    node1.vm.provider "virtualbox" do |vb|
      vb.name = "node1"
    end
  end

  # Define Node2 VM
  config.vm.define "node2" do |node2|
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", type: "dhcp"
    node2.vm.provider "virtualbox" do |vb|
      vb.name = "node2"
    end
  end

  # Synced folder to enable host-machine and guest-machine communication
  config.vm.synced_folder ".", "/vagrant", disabled: true
end
