locals {
  exec_setup = 0
}

resource "null_resource" "remote-exec" {
    connection {
      host        = var.compute_public_ip
      user        = "opc"
      private_key = var.ssh_private_key
      timeout     = "5m"
    }

    provisioner "file" {
      source      = local_file.autonomous_database_wallet_file.filename
      destination = "/tmp/autonomous_database_wallet.zip"
    }

    provisioner "file" {
      source      = "./modules/setup/scripts/bootstrap.sh"
      destination = "/tmp/bootstrap.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo /tmp/bootstrap.sh '${var.app_name}' '${var.wallet_password}'",
      ]
    }
}

resource "null_resource" "remove-ssh-key" {
    count       = var.keep_generated_ssh_key ? 0 : 1
    depends_on = [null_resource.remote-exec]

    connection {
      host        = var.compute_public_ip
      user        = "opc"
      private_key = var.ssh_private_key
      timeout     = "5m"
    }

    provisioner "file" {
      content     = var.ssh_public_key
      destination = "/home/opc/.ssh/authorized_keys"
    }

}