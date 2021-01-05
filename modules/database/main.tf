locals {
  compartment_id = var.target_compartment_id
  display_name   = join("-", [var.db_name, formatdate("YYYYMMDDhhmmss", timestamp())])
}

resource "oci_database_autonomous_database" "instance" {
  admin_password           = var.admin_password
  compartment_id           = local.compartment_id
  cpu_core_count           = "1"
  db_name                  = var.db_name
  db_version               = "21c"
  db_workload              = "OLTP"
  data_storage_size_in_tbs = 1
  defined_tags = {
  }
  display_name = local.display_name
  freeform_tags = {
  }
  
  is_free_tier            = "true"
  // license_model = "LICENSE_INCLUDED"
}

data "oci_database_autonomous_databases" "autonomous_databases" {
  #Required
  compartment_id = local.compartment_id

  #Optional
  display_name                     = local.display_name
  db_workload                      = "OLTP"
}