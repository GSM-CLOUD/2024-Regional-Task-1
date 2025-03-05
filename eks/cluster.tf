module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.31"
  cluster_name = var.cluster_name

  cluster_endpoint_public_access = true

  vpc_id = var.vpc_id
  subnet_ids = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  enable_cluster_creator_admin_permissions = false

  cluster_encryption_config = {
  resources = ["secrets"]
  provider = {
    key_arn = aws_kms_key.eks_kms.arn
  }
}


  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}
