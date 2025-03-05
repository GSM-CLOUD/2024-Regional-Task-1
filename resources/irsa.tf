module "user-app-irsa-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-user-app-sa-role"

  oidc_providers = {
    ex = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.prefix}:${var.service_account_name}"]
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