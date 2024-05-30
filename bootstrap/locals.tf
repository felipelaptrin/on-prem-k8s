locals {
  K3s_version = "v1.30.1+k3s1" # Check all available versions on GitHub releases page: https://github.com/k3s-io/k3s/releases
  # Use "vagrant ssh-config" to get the values below
  cluster = {
    "management" : {
      "192.168.56.10" : {
        "user" : "vagrant",
        "password" : "vagrant",
        "port" : 2222
      },
    },
    "dev" : {
      "192.168.56.11" : {
        "user" : "vagrant",
        "password" : "vagrant",
        "port" : 22
      },
    }
  }
}
