module "user-app-irsa-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-user-app-sa-role"

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["skills:user"]
    }
  }
}

resource "aws_iam_policy" "secrets_store_read_policy" {
  name = "${var.prefix}-secrets-store-read-policy"
  description = "${var.prefix}-secrets-store-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = var.secrets_manager_arn
      },
      {
        Effect = "Allow"
        Action = "secretsmanager:GetRandomPassword"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_store_read_policy_attachment" {
  role       = module.user-app-irsa-role.iam_role_name
  policy_arn = aws_iam_policy.secrets_store_read_policy.arn
}

module "cluster-autoscaler-irsa-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-cluster-autoscaler-sa-role"

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name = "${var.prefix}-cluter-autoscaler-policy"
  description = "${var.prefix}-cluter-autoscaler-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_policy_attachment" {
  role       = module.cluster-autoscaler-irsa-role.iam_role_name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

module "fluent-bit-irsa-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-fluent-bit-sa-role"

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:fluent-bit"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "fluent_bit_policy_attachment" {
  role       = module.fluent-bit-irsa-role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_policy" "fluentbit_fargate_policy" {
  name = "${var.prefix}-fluentbit-fargate-policy"
  description = "${var.prefix}-fluentbit-fargate-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        "Action": [
			    "logs:CreateLogStream",
			    "logs:CreateLogGroup",
			    "logs:DescribeLogStreams",
			    "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
		    ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit_fargate_policy_attachment" {
  role       = var.fargate_profile_role_name
  policy_arn = aws_iam_policy.fluentbit_fargate_policy.arn
}