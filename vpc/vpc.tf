module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-vpc"
  cidr = "10.100.0.0/16"

  azs = ["${var.region}a", "${var.region}b"]
  public_subnets = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnets = ["10.100.11.0/24", "10.100.12.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway = true
  single_nat_gateway = false

  igw_tags = {
    "Name" = "${var.prefix}-igw"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "protected_subnet_a" {
    vpc_id = module.vpc.vpc_id
    cidr_block = "10.100.21.0/24"
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = false

    tags = {
      Name = "${var.prefix}-protected-subnet-a"
    }
}

resource "aws_subnet" "protected_subnet_b" {
    vpc_id = module.vpc.vpc_id
    cidr_block = "10.100.22.0/24"
    availability_zone = "${var.region}b"
    map_public_ip_on_launch = false

    tags = {
      Name = "${var.prefix}-protected-subnet-b"
    }
}

resource "aws_route_table" "protected_route_table" {
    vpc_id = module.vpc.vpc_id
    tags = {
        Name = "${var.prefix}-protected-rtb"
    }  
}

resource "aws_route_table_association" "protected_subnet_a" {
    subnet_id = aws_subnet.protected_subnet_a.id
    route_table_id = aws_route_table.protected_route_table.id
}

resource "aws_route_table_association" "protected_subnet_b" {
    subnet_id = aws_subnet.protected_subnet_b.id
    route_table_id = aws_route_table.protected_route_table.id
}