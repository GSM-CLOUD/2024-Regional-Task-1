output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "worker_node_security_group_id" {
  value = aws_security_group.worker_node_sg.id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "plane_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_addon_node_group_id" {
  value = module.eks_managed_node_group_addon.node_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "app_nodegroup_name" {
  value = module.eks_managed_node_group_app.node_group_id
}