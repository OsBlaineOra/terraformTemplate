terraform {
  required_version = ">= 0.13.0"
}

locals {
  database_count = var.create_database ? 1 : 0
  compute_count = var.create_compute ? 1 : 0
  common_tags = {
    Reference = "terraform-template"
  }
}

module "network" {
  source                = "./modules/network"
  app_name              = var.app_name
  target_compartment_id = var.compartment_ocid
  common_tags           = local.common_tags
}

module "database" {
  // count                 = local.database_count
  source                = "./modules/database"
  db_name               = var.app_name
  target_compartment_id = var.compartment_ocid
  admin_password        = var.admin_password
  common_tags           = local.common_tags
}

module "compute" {
  // count                    = local.compute_count
  source                   = "./modules/compute"
  app_name                 = var.app_name
  region                   = var.region
  tenancy_ocid             = var.tenancy_ocid
  target_compartment_id    = var.compartment_ocid
  subnet_id                = module.network.subnet.id
  instance_shape           = var.instance_shape
  ssh_public_key           = var.ssh_public_key
  common_tags              = local.common_tags
}

module "setup" {
  // count                     = local.compute_count
  source                    = "./modules/setup"
  app_name                  = var.app_name
  compute_public_ip         = module.compute.compute_public_ip
  ssh_private_key           = module.compute.instance_keys.private_key_pem
  database_id               = module.database.instance.id
  wallet_password           = module.setup.autonomous_database_wallet_password
  admin_password            = var.admin_password
  ssh_public_key            = var.ssh_public_key
  keep_generated_ssh_key    = var.keep_generated_ssh_key
  common_tags               = local.common_tags
}
