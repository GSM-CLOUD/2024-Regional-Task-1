resource "aws_eks_access_entry" "bastion_eks_access" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.root_arn
}

resource "aws_eks_access_policy_association" "bastion_eks_access_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.root_arn

  access_scope {
    type = "cluster"
  }
}