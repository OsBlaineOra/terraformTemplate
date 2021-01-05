resource "random_string" "autonomous_database_wallet_password" {
  length  = 16
  special = true
  override_special = "@*()-_=+[]{}<>:"
}

resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  autonomous_database_id = var.database_id
  password               = random_string.autonomous_database_wallet_password.result
  base64_encode_content  = "true"
}

resource "local_file" "autonomous_database_wallet_file" {
  content_base64 = oci_database_autonomous_database_wallet.autonomous_database_wallet.content
  filename       = "${path.module}/autonomous_database_wallet.zip"
}