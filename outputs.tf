output "cluster_id" {
  value       = join("", aws_elasticache_cluster.default.*.id)
  description = "Cluster ID"
}

output "security_group_id" {
  value       = join("", aws_security_group.default.*.id)
  description = "Security Group ID"
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

output "clusters_cache_node_endpoints" {
  value = flatten([for cluster in aws_elasticache_cluster.default : [for node in cluster.cache_nodes : node.address]])
  description = "A list of cache node endpoints"
}

