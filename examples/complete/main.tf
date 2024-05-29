provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.2.0"

  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.1"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "memcached" {
  source                  = "../../"
  az_mode                 = var.az_mode
  availability_zone       = var.availability_zone
  vpc_id                  = module.vpc.vpc_id
  allowed_security_groups = [module.vpc.vpc_default_security_group_id]
  subnets                 = module.subnets.private_subnet_ids
  cluster_size            = var.cluster_size
  instance_type           = var.instance_type
  engine_version          = var.engine_version
  apply_immediately       = true
  zone_id                 = var.zone_id

  elasticache_parameter_group_family = var.elasticache_parameter_group_family

  context = module.this.context
}
