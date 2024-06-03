# on-prem-k8s

## Deployment

```hcl
k3s_version = "v1.28.10+k3s1"
cert_manager_version = "v1.14.5"
rancher_version = "v2.8.4"
rancher_endpoint = "192.168.56.26.sslip.io"
management_cluster = {
  host        = "127.0.0.1",
  user        = "vagrant"
  password    = "vagrant"
  port        = 2222
  private_key = "/home/flat/Desktop/folders/on-prem-k8s/.vagrant/machines/rancher/virtualbox/private_key"
}
managed_cluster = {
  development = [{
    host        = "127.0.0.1",
    user        = "vagrant"
    password    = "vagrant"
    port        = 2200
    private_key = "/home/flat/Desktop/folders/on-prem-k8s/.vagrant/machines/node1/virtualbox/private_key"
  },{
    host        = "127.0.0.1",
    user        = "vagrant"
    password    = "vagrant"
    port        = 2201
    private_key = "/home/flat/Desktop/folders/on-prem-k8s/.vagrant/machines/node2/virtualbox/private_key"
  }]
}
```