locals {
  k3s_intall_script_path = "${path.module}/scripts/install-k3s.sh"
  k3s_install_command    = "/bin/bash /tmp/install-k3s.sh ${local.K3s_version}"
}

resource "null_resource" "install_k3s" {
  connection {
    type        = "ssh"
    host        = "127.0.0.1"
    user        = "vagrant"
    password    = "vagrant"
    port        = "2222"
    private_key = file("/home/flat/Desktop/folders/on-prem-k8s/.vagrant/machines/rancher/virtualbox/private_key")
  }

  provisioner "file" {
    source      = local.k3s_intall_script_path
    destination = "/tmp/install-k3s.sh"
  }

  provisioner "remote-exec" {
    inline = [local.k3s_install_command]
  }

  # Triggered if K3s version changed or script is modified
  triggers = {
    script_hash = md5(format("%s%s", file(local.k3s_intall_script_path), local.k3s_install_command))
  }
}
