output "id" {
  value       = join("", aws_elasticache_cluster.default.*.id)
  description = "Cluster ID"
}

output "security_group_id" {
  value       = join("", aws_security_group.default.*.id)
  description = "Security Group ID"
}

output "config_host" {
  value       = module.dns_config.hostname
  description = "Cluster configuration endpoint hostname"
}

output "hosts" {
  value       = join(",", null_resource.host.*.triggers.name)
  description = "Cluster hosts"
}
