module "vpc" {
  source = "./vpc"
  prefix = var.prefix
  region = var.region
  cluster_name = var.cluster_name
}

module "s3" {
  source = "./s3"
  prefix = var.prefix

  depends_on = [ module.vpc ]
}

module "ecr" {
  source = "./ecr"

  depends_on = [ module.s3 ]
}

module "eks" {
  source = "./eks"
  cluster_name = var.cluster_name
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  root_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  eks_addon_nodegroup_instance_type = "t4g.large"
  eks_app_nodegroup_instance_type = "m6g.large"
  ami_type = "AL2023_ARM_64_STANDARD"

  depends_on = [ module.ecr ]
}

module "ec2" {
  source = "./bastion"
  prefix = var.prefix
  aws_ami = data.aws_ami.al2023_ami_arm.id
  vpc_id = module.vpc.vpc_id
  cluster_security_group_id = module.eks.cluster_security_group_id
  node_security_group_id = module.eks.node_security_group_id
  public_subnets = module.vpc.public_subnets
  eks_cluster_name = module.eks.cluster_name
  bastion_port = 2222
  bucket_name = module.s3.bucket_name
  account_id = data.aws_caller_identity.current.account_id

  depends_on = [ module.eks ]
}

module "ec2_amd" {
  source = "./ec2_amd"
  prefix = var.prefix
  ami_id = data.aws_ami.al2023_ami_amd.id
  key_name = module.ec2.key_name
  public_subnets = module.vpc.public_subnets
  instance_type = "t3.small"
  instance_profile = module.ec2.instance_profile
  vpc_id = module.vpc.vpc_id
  bucket_name = module.s3.bucket_name
  account_id = data.aws_caller_identity.current.account_id

  depends_on = [ module.ec2 ]
}

module "redis" {
  source = "./redis"
  vpc_id = module.vpc.vpc_id
  protected_subnets = module.vpc.protected_subnets
  prefix = var.prefix
  eks_node_sg_id = module.eks.node_security_group_id
  eks_cluster_sg_id = module.eks.cluster_security_group_id
  redis_port = 6389
  redis_node_type = "cache.t4g.small"
  worker_node_security_group_id = module.eks.worker_node_security_group_id
  plane_security_group_id = module.eks.plane_security_group_id

  depends_on = [ module.ec2_amd ]
}

module "docdb" {
  source = "./docdb"
  prefix = var.prefix
  protected_subnets = module.vpc.protected_subnets
  vpc_id = module.vpc.vpc_id
  eks_node_sg_id = module.eks.node_security_group_id
  eks_cluster_sg_id = module.eks.cluster_security_group_id
  mongodb_password = var.mongodb_password
  mongodb_username = var.mongodb_username
  db_instance_class = "db.t4g.medium"
  docdb_port = 27018
  worker_node_security_group_id = module.eks.worker_node_security_group_id
  plane_security_group_id = module.eks.plane_security_group_id

  depends_on = [ module.redis ]
}

module "secrets_manager" {
  source = "./secrets_manager"
  prefix = var.prefix

  depends_on = [ module.docdb ]
}

module "lb_controller" {
  source = "./lb_controller"
  prefix = var.prefix
  eks_cluster_name = module.eks.cluster_name
  eks_addon_node_group_id = module.eks.eks_addon_node_group_id
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id = module.vpc.vpc_id

  depends_on = [ module.secrets_manager ]
}

module "resources" {
  source = "./resources"
  prefix = var.prefix
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  namespace = var.namespace_name
  redis_cluster_endpoint = module.redis.redis_cluster_endpoint
  redis_cluster_port = module.redis.redis_cluster_port
  ecr_token_uri = "${module.ecr.ecr_token_uri}:latest"
  mongodb_cluster_endpoint = module.docdb.docdb_cluster_endpoint
  ecr_user_uri = "${module.ecr.ecr_user_uri}:latest"
  mongodb_cluster_port = module.docdb.docdb_cluster_port
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
  region = var.region
  secret_manager_name = module.secrets_manager.secret_manager_name
  app_nodegroup_name = module.eks.app_nodegroup_name
  account_id = data.aws_caller_identity.current.account_id
  secrets_manager_arn = module.secrets_manager.secrets_manager_arn
  service_name = var.service_name
  alb_name = var.alb_name

  depends_on = [ module.lb_controller ]
}