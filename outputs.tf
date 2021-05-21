output "cluster_id" {
  value       = join("", aws_elasticache_cluster.default.*.id)
  description = "Cluster ID"
}

output "security_group_id" {
  value       = module.security_group.id
  description = "Cluster Security Group ID"
}

output "security_group_arn" {
  value       = module.security_group.arn
  description = "Cluster Security Group ARN"
}

output "security_group_name" {
  value       = module.security_group.name
  description = "Cluster Security Group name"
}

output "cluster_address" {
  value       = join("", aws_elasticache_cluster.default.*.cluster_address)
  description = "Cluster address"
}

output "cluster_configuration_endpoint" {
  value       = join("", aws_elasticache_cluster.default.*.configuration_endpoint)
  description = "Cluster configuration endpoint"
}

output "hostname" {
  value       = module.dns.hostname
  description = "Cluster hostname"
}

output "cluster_urls" {
  value       = null_resource.cluster_urls.*.triggers.name
  description = "Cluster URLs"
}
