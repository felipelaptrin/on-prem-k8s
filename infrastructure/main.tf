locals {
  k3s_bootstrap_remote_folder_path = "/tmp/bootstrap"
  k3s_install_script_path          = "${path.module}/bootstrap"
  k3s_install_command              = "/bin/bash ${local.k3s_bootstrap_remote_folder_path}/install.sh ${var.k3s_version} ${var.cert_manager_version} ${var.rancher_version} ${local.k3s_bootstrap_remote_folder_path}"
}

data "archive_file" "check_if_bootstrap_needs_to_run" {
  type        = "zip"
  source_dir  = local.k3s_install_script_path
  output_path = "/tmp/k3s-bootstrap.zip"
}

resource "null_resource" "install_k3s" {
  connection {
    type        = "ssh"
    host        = var.management_cluster["host"]
    user        = var.management_cluster["user"]
    password    = var.management_cluster["password"]
    port        = var.management_cluster["port"]
    private_key = file(var.management_cluster["private_key"])
  }

  provisioner "file" {
    source      = local.k3s_install_script_path
    destination = local.k3s_bootstrap_remote_folder_path
  }

  # We can´t have a single 'remote-exec' for running 2 commands because it will
  # consider that this resource was successful if the last inline command run fine
  provisioner "remote-exec" {
    inline = [
      local.k3s_install_command,
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf ${local.k3s_bootstrap_remote_folder_path}",
    ]
  }

  # Triggered if script (or inputs to this script) and Helm Chart Value changed
  triggers = {
    script_hash     = data.archive_file.check_if_bootstrap_needs_to_run.output_sha
    install_command = md5(local.k3s_install_command)
  }
}
