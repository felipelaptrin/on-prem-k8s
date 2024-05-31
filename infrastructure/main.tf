locals {
  k3s_install_script_path = "${path.module}/bootstrap"
  k3s_install_command     = "/bin/bash /tmp/bootstrap/install.sh ${var.k3s_version} ${var.cert_manager_version}"
}

data "archive_file" "check_if_bootstrap_needs_to_run" {
  type        = "zip"
  source_dir  = local.k3s_install_script_path
  output_path = "/tmp/data.zip"
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
    destination = "/tmp/bootstrap"
  }

  provisioner "remote-exec" {
    inline = [
      local.k3s_install_command,
      "rm -rf /tmp/bootstrap"
    ]
  }

  # Triggered if script (or inputs to this script) and Helm Chart Value changed
  triggers = {
    script_hash     = data.archive_file.check_if_bootstrap_needs_to_run.output_sha
    install_command = md5(local.k3s_install_command)
  }
}
