locals {
  bootstrap_remote_folder_path = "/tmp/bootstrap"
  bootstrap_folder_path        = "${path.module}/bootstrap"
  rancher_install_command      = "/bin/bash ${local.bootstrap_remote_folder_path}/install-manager.sh ${var.k3s_version} ${var.cert_manager_version} ${var.rancher_version} ${local.bootstrap_remote_folder_path}"
  nodes = flatten([
    for cluster_name, cluster_value in var.managed_cluster : [
      for index, node_value in cluster_value.nodes :
      merge({ "cluster" : cluster_name }, node_value)
    ]
  ])
}

data "archive_file" "check_if_bootstrap_needs_to_run" {
  type        = "zip"
  source_dir  = local.bootstrap_folder_path
  output_path = "/tmp/k3s-bootstrap.zip"
}

resource "null_resource" "bootstrap_rancher" {
  connection {
    type        = "ssh"
    host        = var.management_cluster["host"]
    user        = var.management_cluster["user"]
    password    = var.management_cluster["password"]
    port        = var.management_cluster["port"]
    private_key = file(var.management_cluster["private_key"])
  }

  provisioner "file" {
    source      = local.bootstrap_folder_path
    destination = local.bootstrap_remote_folder_path
  }

  # We can´t have a single 'remote-exec' for running 2 commands because it will
  # consider that this resource was successful if the last inline command run fine
  provisioner "remote-exec" {
    inline = [
      local.rancher_install_command,
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.bootstrap_remote_folder_path}",
    ]
  }

  # Triggered if script (or inputs to this script) and Helm Chart Value changed
  triggers = {
    script_hash     = data.archive_file.check_if_bootstrap_needs_to_run.output_sha
    install_command = md5(local.rancher_install_command)
  }
}

resource "rancher2_bootstrap" "this" {
  depends_on       = [null_resource.bootstrap_rancher]
  provider         = rancher2.bootstrap
  initial_password = "ChangedByTerraform"
  telemetry        = false
}

resource "rancher2_cluster_v2" "this" {
  for_each = var.managed_cluster

  provider           = rancher2.admin
  name               = each.key
  kubernetes_version = each.value.kubernetes_version
}

resource "null_resource" "bootstrap_node" {
  depends_on = [null_resource.bootstrap_rancher, rancher2_cluster_v2.this]
  for_each   = { for k, v in local.nodes : k => v }
  connection {
    type        = "ssh"
    host        = each.value["host"]           #"127.0.0.1"
    user        = each.value.user              #"vagrant"
    password    = each.value.password          #"vagrant"
    port        = each.value.port              # 2200
    private_key = file(each.value.private_key) #file("/Users/felipe/Desktop/folders/personal/rancher/.vagrant/machines/node01/vmware_fusion/private_key")
  }

  provisioner "file" {
    source      = local.bootstrap_folder_path
    destination = local.bootstrap_remote_folder_path
  }

  # We can´t have a single 'remote-exec' for running 2 commands because it will
  # consider that this resource was successful if the last inline command run fine
  provisioner "remote-exec" {
    inline = [
      "/bin/bash ${local.bootstrap_remote_folder_path}/install-node.sh",
      "${rancher2_cluster_v2.this[each.value.cluster].cluster_registration_token[0].insecure_node_command} ${join(" ", [for x in each.value.role : format("--%s", x)])}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.bootstrap_remote_folder_path}",
    ]
  }

  triggers = {
    always = timestamp()
  }
}
