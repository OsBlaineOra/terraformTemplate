output "compute_public_ip" {
  value = oci_core_instance.compute.public_ip
}

output "instance" {
  value = oci_core_instance.compute
}

output "instance_keys" {
  value = tls_private_key.ssh_keypair
}
