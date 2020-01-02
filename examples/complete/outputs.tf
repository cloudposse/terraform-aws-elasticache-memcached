output "public_subnet_cidrs" {
  value       = module.subnets.public_subnet_cidrs
  description = "Public subnet CIDRs"
}

output "private_subnet_cidrs" {
  value       = module.subnets.private_subnet_cidrs
  description = "Private subnet CIDRs"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC CIDR"
}

output "cluster_id" {
  value       = module.memcached.cluster_id
  description = "Cluster ID"
}

output "security_group_id" {
  value       = module.memcached.security_group_id
  description = "Security Group ID"
}

output "cluster_address" {
  value       = module.memcached.cluster_address
  description = "Cluster address"
}

output "cluster_configuration_endpoint" {
  value       = module.memcached.cluster_configuration_endpoint
  description = "Cluster configuration endpoint"
}

output "hostname" {
  value       = module.memcached.hostname
  description = "Cluster hostname"
}

output "cluster_urls" {
  value       = module.memcached.cluster_urls
  description = "Cluster URLs"
}
