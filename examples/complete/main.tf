provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.18.1"

  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.33.0"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "memcached" {
  source = "../../"

  az_mode           = var.az_mode
  availability_zone = var.availability_zone
  vpc_id            = module.vpc.vpc_id
  subnets           = module.subnets.private_subnet_ids
  cluster_size      = var.cluster_size
  instance_type     = var.instance_type
  engine_version    = var.engine_version
  apply_immediately = true
  zone_id           = var.zone_id

  security_group_rules = [
    {
      type                     = "egress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "Allow all outbound traffic"
    },
    {
      type                     = "ingress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = []
      source_security_group_id = module.vpc.vpc_default_security_group_id
      description              = "Allow all inbound traffic from trusted Security Groups"
    }
  ]

  context = module.this.context
}
