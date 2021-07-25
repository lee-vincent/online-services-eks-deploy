provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "eks-online-services-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  database_subnet_assign_ipv6_address_on_creation    = false
  database_subnet_group_name                         = ""
  default_security_group_egress                      = []
  default_security_group_ingress                     = []
  elasticache_subnet_assign_ipv6_address_on_creation = false
  enable_classiclink                                 = false
  enable_classiclink_dns_support                     = false
  flow_log_cloudwatch_log_group_kms_key_id           = ""
  flow_log_cloudwatch_log_group_retention_in_days    = 0
  flow_log_log_format                                = ""
  intra_subnet_assign_ipv6_address_on_creation       = false
  outpost_arn                                        = ""
  outpost_az                                         = ""
  outpost_subnet_assign_ipv6_address_on_creation     = false
  private_subnet_assign_ipv6_address_on_creation     = false
  public_subnet_assign_ipv6_address_on_creation      = false
  redshift_subnet_assign_ipv6_address_on_creation    = false
  vpc_flow_log_permissions_boundary                  = ""
  vpn_gateway_az                                     = ""

  name                 = "vpc-${local.cluster_name}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnets[0]


  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}
