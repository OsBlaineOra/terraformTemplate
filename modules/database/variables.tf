variable "target_compartment_id" {
  description = "OCID of the compartment where the compute is being created"
  type        = string
}

variable "common_tags" {
  description = "Tags"
  type        = map(string)
}

variable "admin_password" {
  description = "Database Admin Password"
}

variable "db_name" {
  description = "Database Name"
}