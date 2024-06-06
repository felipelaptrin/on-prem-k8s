# on-prem-k8s

This repository helps you deploy Kubernetes in an on-premise environment using Rancher and OpenTofu (Terraform). This is not a production-ready template since Rancher is being installed in a single node but can give you a good understanding of how Rancher should be set up.

## Deployment
The deployment should be trivial to accomplish. To make the development live easier I set up [DevBox](https://www.jetify.com/devbox/docs/) in the project. So make sure you have it installed!

1) Make sure you have nodes in place
The nodes should be able to reach (network) themselves. In case you don't have physical servers or VMs you can still test this by locally deploying VMs using Vagrant and VMware Fusion (Hypervisor). To do so, just follow the step below:

- [Install Vagrant](https://developer.hashicorp.com/vagrant/docs/installation): We are using Vagrant to automate the creation of VMs using `Vagrantfile`.
- [Install VMWare Fusion Pro](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion): We could have used any other hypervisor (e.g. Virtualbox) to deploy the VMs but I think VMware Fusion is a great option because it's one of the few free (for personal use) hypervisors that you can use with M-series Macbooks.
- [Install VMware Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility): This will provide VMware provider plugin (that we are installing next) with various functionalities.
- [Install Vagrant VMware plugin](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation): Simply run `vagrant plugin update vagrant-vmware-desktop`.
https://profile.broadcom.com/web/registration

After this is done, simply run `vagrant up` and the VMs will be created for you.

2) Install dependencies
Make sure you have [DevBox](https://www.jetify.com/devbox/docs/) installed.

```sh
devbox shell
```

3) Configure OpenTofu (Terraform) variables

The `infrastructure` folder contains all the terraform files that will deploy Rancher and the managed Kubernetes cluster. You can check the `variables.tf` file to understand all the inputs of the code. You can create a `vars.tfvars` file with your desired configuration (make sure to create this file inside the `infrastructure` folder). A completely valid configuration can be seen below:

```hcl
k3s_version          = "v1.28.10+k3s1"
cert_manager_version = "v1.14.5"
rancher_version      = "v2.8.4"
rancher_endpoint     = "192.168.110.10.sslip.io"
management_cluster = {
  host        = "127.0.0.1",
  user        = "vagrant"
  password    = "vagrant"
  port        = 2222
  private_key = "/Users/felipe/Desktop/folders/personal/rancher/.vagrant/machines/rancher-manager/vmware_fusion/private_key"
}
managed_cluster = {
  development = {
    kubernetes_version = "v1.28.10+rke2r1"
    nodes = [{
      host        = "127.0.0.1",
      user        = "vagrant"
      password    = "vagrant"
      port        = 2200
      private_key = "/Users/felipe/Desktop/folders/personal/rancher/.vagrant/machines/node01/vmware_fusion/private_key",
      role        = ["controlplane"]
      },{
      host        = "127.0.0.1",
      user        = "vagrant"
      password    = "vagrant"
      port        = 2201
      private_key = "/Users/felipe/Desktop/folders/personal/rancher/.vagrant/machines/node02/vmware_fusion/private_key"
      role        = ["etcd"]
      },
      {
      host        = "127.0.0.1",
      user        = "vagrant"
      password    = "vagrant"
      port        = 2202
      private_key = "/Users/felipe/Desktop/folders/personal/rancher/.vagrant/machines/node03/vmware_fusion/private_key"
      role        = ["worker"]
      }]
  }
}
```

PS: Make sure to edit `managed_cluster.<cluster-name>.nodes[]` accordingly. If you are using Vagrant to create the machines you can run `vagrant ssh-config` to get the `host`, `user`, `password`, `port` and `private_key`.

The given example creates a managed K8S node with three nodes, and each node as a single role (etcd, controlplane, worker). As commented before, this is NOT a production-ready example. Please check Rancher [documentation](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/checklist-for-production-ready-clusters/recommended-cluster-architecture).

4) Configure Rancher Helm chart values

If you are not using Vagrant, you will need to change the `hostname` of the `infrastructure/bootstrap/values.yaml` file to be the value of the host that will have Rancher installed. If you are using Vagrant, there is no need to change!

5) Deploy using OpenTofu

Run the following commands:

```sh
cd infrastructure
tofu init
tofu apply --var-file="vars.tfvars"
```

6) Access the local rancher endpoint

```sh
192.168.110.10.sslip.io
```

This will be different if you didn't use Vagrant.

7) Are you satisfied? Destroy everything!

From the root of this repository run

```
vagrant destroy
```