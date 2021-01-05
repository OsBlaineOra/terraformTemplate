locals {
  compartment_id                  = var.target_compartment_id
  app_name                        = var.app_name
  display_name                    = join("-", [local.app_name, formatdate("YYYYMMDDhhmmss", timestamp())])
  num_of_ads                      = length(data.oci_identity_availability_domains.ads.availability_domains)
  ads                             = local.num_of_ads > 1 ? flatten([
                                        for ad_shapes in data.oci_core_shapes.this : [
                                            for shape in ad_shapes.shapes : ad_shapes.availability_domain if shape.name == var.instance_shape
                                        ]
                                    ]) : [for ad in data.oci_identity_availability_domains.ads.availability_domains : ad.name]
}

# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "this" {
  compartment_id           = local.compartment_id # Required
  operating_system         = var.image_os         # Optional
  operating_system_version = var.image_os_version # Optional
  shape                    = var.instance_shape   # Optional
  sort_by                  = "TIMECREATED"        # Optional
  sort_order               = "DESC"               # Optional
}

data "oci_core_shapes" "this" {
  count               = local.num_of_ads > 1 ? local.num_of_ads : 0 
  #Required
  compartment_id      = local.compartment_id

  #Optional
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index].name
  image_id            = data.oci_core_images.this.images[0].id
}

data "oci_identity_compartment" "this" {
  id = local.compartment_id
}

# Generate the private and public key pair
resource "tls_private_key" "ssh_keypair" {
  algorithm = "RSA" # Required
  rsa_bits  = 2048  # Optional
}

resource "oci_core_instance" "compute" {
  display_name         = local.display_name
  availability_domain  = local.ads[0]
  compartment_id       = local.compartment_id
  shape                = var.instance_shape
  preserve_boot_volume = false
  freeform_tags        = var.common_tags

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.this.images[0].id
  }

  metadata = {
    ssh_authorized_keys  = join("", [tls_private_key.ssh_keypair.public_key_openssh, var.ssh_public_key])
    tenancy_id           = var.tenancy_ocid
  }
}