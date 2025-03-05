module "eks_blueprints_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"

    cluster_name = module.eks.cluster_name
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_version = module.eks.cluster_version
    oidc_provider_arn = module.eks.oidc_provider_arn

    eks_addons = {
        vpc-cni = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        coredns = {
            most_recent = true
            configuration_values = jsonencode({
                nodeSelector = {
                    "eks.amazonaws.com/nodegroup" = element(split(":", module.eks_managed_node_group_addon.node_group_id), 1)
                }
            })
        }
        metrics-server = {
            most_recent = true
            configuration_values = jsonencode({
                nodeSelector = {
                    "eks.amazonaws.com/nodegroup" = element(split(":", module.eks_managed_node_group_addon.node_group_id), 1)
                }
            })
        }
    }

    tags = {
        "Name" = "${var.prefix}-eks-addons"
    }
  
}