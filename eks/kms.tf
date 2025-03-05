resource "aws_kms_key" "eks_kms" {
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_alias" "eks_kms" {
  target_key_id = aws_kms_key.eks_kms.key_id
  name = "alias/${var.prefix}-eks-kms"
}