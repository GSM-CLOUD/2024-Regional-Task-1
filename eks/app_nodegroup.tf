module "eks_managed_node_group_app" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = "${var.prefix}-eks-app-nodegroup"
  cluster_name = module.eks.cluster_name
  cluster_version = "1.31"

  subnet_ids = var.private_subnets

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [module.eks.node_security_group_id, aws_security_group.worker_node_sg.id]

  min_size = 2
  max_size = 4
  desired_size = 2

  instance_types = [var.eks_app_nodegroup_instance_type]
  ami_type = "AL2023_ARM_64_STANDARD"
  capacity_type = "ON_DEMAND"

  create_iam_role = false

  iam_role_use_name_prefix = false

  iam_role_arn = aws_iam_role.nodegroup_role.arn

  cluster_service_cidr = module.eks.cluster_service_cidr

  labels = {
    "app" = "app"
  }

  tags = {
    "Name" = "${var.prefix}-eks-app-nodegroup"
  }
}