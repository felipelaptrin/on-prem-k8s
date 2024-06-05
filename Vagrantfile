require 'yaml'
settings = YAML.load_file(File.join(File.dirname(__FILE__), 'vagrant.yaml'))

Vagrant.configure("2") do |config|
  config.vm.box = settings['box_name']

  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|
      vm.vm.hostname = vm_config['name']
      vm.vm.network "private_network", ip: vm_config['ip']
      vm.vm.synced_folder ".", "/vagrant", disabled: false

      vm.vm.provider "vmware_fusion" do |vb|
        vb.memory = vm_config['memory']
        vb.cpus = vm_config['cpus']
      end
    end
  end
end