module "fargate_profile_app" {
    source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

    name = "${var.prefix}-eks-app-profile"
    cluster_name = module.eks.cluster_name

    create_iam_role = false
    iam_role_arn = aws_iam_role.fargate_profile_role.arn

    subnet_ids = var.private_subnets

    selectors = [{
        namespace = "skills"
        labels = {
            "app" = "token"
        }
    }]

    tags = {
        "Name" = "${var.prefix}-eks-app-profile"
    }
}