terraform {
  required_version = "~> 1.7"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.1.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
  }
}

provider "local" {}

provider "rancher2" {
  alias = "bootstrap"

  api_url = "https://${var.rancher_endpoint}"
  # token_key = data.external.fetch_rancher_token.result["output"]
  insecure  = true
  bootstrap = true
}

provider "rancher2" {
  alias = "admin"

  api_url   = rancher2_bootstrap.this.url
  token_key = rancher2_bootstrap.this.token
  insecure  = true
}
