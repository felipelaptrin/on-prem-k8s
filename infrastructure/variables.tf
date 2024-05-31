variable "k3s_version" {
  description = "K3s version that will be used in the management cluster (Rancher). Check all available versions on GitHub releases page: https://github.com/k3s-io/k3s/releases"
  type        = string
}

variable "cert_manager_version" {
  description = "Version of the Cert Manager that will be deployed, as a Rancher dependency. Check all available versions on Github releases page: https://github.com/cert-manager/cert-manager/releases"
  type        = string
}

variable "management_cluster" {
  description = "Defines the management cluster that will be created."
  type = object({
    host        = string
    user        = string
    password    = string
    port        = number
    private_key = string
  })
}

variable "managed_cluster" {
  description = "Defines all the clusters that will be created. Also defines all the nodes of the cluster."
  type = map(list(object({
    host        = string
    user        = string
    password    = string
    port        = number
    private_key = string
  })))
}
