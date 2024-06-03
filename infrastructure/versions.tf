terraform {
  required_version = "~> 1.8.4"

  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.1.0"
    }
  }
}

provider "local" {}

# Configure the Rancher2 provider to admin
provider "rancher2" {
  api_url = "https://rancher.my-domain.com"
}
