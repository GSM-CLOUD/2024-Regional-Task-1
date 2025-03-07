variable "region" {
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  default = "default"
}

variable "prefix" {
  default = "skills"
}

variable "cluster_name" {
  default = "skills-eks-cluster"
}

variable "mongodb_password" {
  default = "kjh113106"
  sensitive = true
}

variable "mongodb_username" {
  default = "root"
  sensitive = true
}

variable "namespace_name" {
  default = "skills"
}

variable "service_name" {
  default = "service-user"
}

variable "alb_name" {
  default = "skills-user-alb"
}

variable "fluent_bit_ns" {
  default = "amazon-cloudwatch"
}

variable "user_log_group_name" {
  default = "/aws/app/user"
}

variable "fluent_bit_fargate_ns" {
  default = "aws-observability"
}