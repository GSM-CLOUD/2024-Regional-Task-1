output "bastion_role_arn" {
  value = aws_iam_role.bastion_role.arn
}

output "key_name" {
  value = aws_key_pair.bastion-key-pair.key_name
}

output "instance_profile" {
  value = aws_iam_instance_profile.bastion_instance_profile.name
}