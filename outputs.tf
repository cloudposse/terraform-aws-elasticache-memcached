output "cluster_id" {
  value       = join("", aws_elasticache_cluster.default[*].id)
  description = "Cluster ID"
}

output "security_group_id" {
  value       = module.aws_security_group.id
  description = "The ID of the created security group"
}

output "security_group_arn" {
  value       = module.aws_security_group.arn
  description = "The ARN of the created security group"
}

output "security_group_name" {
  value       = module.aws_security_group.name
  description = "The name of the created security group"
}

output "cluster_address" {
  value       = join("", aws_elasticache_cluster.default[*].cluster_address)
  description = "Cluster address"
}

output "cluster_configuration_endpoint" {
  value       = join("", aws_elasticache_cluster.default[*].configuration_endpoint)
  description = "Cluster configuration endpoint"
}

output "hostname" {
  value       = module.dns.hostname
  description = "Cluster hostname"
}

output "cluster_urls" {
  value       = null_resource.cluster_urls[*].triggers.name
  description = "Cluster URLs"
}
