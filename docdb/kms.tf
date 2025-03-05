resource "aws_kms_key" "docdb_kms" {
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_alias" "docdb_kms" {
  target_key_id = aws_kms_key.docdb_kms.key_id
  name = "alias/${var.prefix}-docdb-kms"  
}