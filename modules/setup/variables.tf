variable "compute_public_ip" {}
variable "ssh_private_key" {}
variable "app_name" {}
variable "admin_password" {}
variable "database_id" {}
variable "wallet_password" {}
variable "keep_generated_ssh_key" {}
variable "ssh_public_key" {}

variable "common_tags" {
  description = "Tags"
  type        = map(string)
}