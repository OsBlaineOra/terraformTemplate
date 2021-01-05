output "compartment_id" {
  value = var.compartment_ocid
}

output "db_wallet_password" {
  value = module.setup.autonomous_database_wallet_password
}

output "compute_instance_public_ip" {
  value = module.compute.instance.public_ip
}

output "generated_instance_ssh_private_key" {
  value = var.keep_generated_ssh_key ? module.compute.instance_keys.private_key_pem : ""
}