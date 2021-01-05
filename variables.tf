variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
// variable "subnet_id" {  
//   default     = "" # This value has to be defaulted to blank, otherwise terraform apply would request for one.
// }

variable "app_name" {
  description = "Application Name"
}

variable "admin_password" {
  description = "Database Admin Password"
}

variable "instance_shape" {
  description = "Shape of the instance"
  type        = string
}

variable "keep_generated_ssh_key" {
  description = "Auto-generate SSH key pair"
  type        = string
}

variable "ssh_public_key" {
  description = "ssh public key used to connect to the compute instance"
  default     = "" # This value has to be defaulted to blank, otherwise terraform apply would request for one.
  type        = string
}

variable "create_compute" {
  description = "Create Compute?"
  type        = bool
  default     = true
}

variable "create_database" {
  description = "Create database?"
  type        = bool
  default     = true
}