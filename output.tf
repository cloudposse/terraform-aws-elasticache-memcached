output "id" {
  value       = "${aws_elasticache_cluster.default.id}"
  description = "Disambiguated ID"
}

output "security_group_id" {
  value       = "${aws_security_group.default.id}"
  description = "Security group id"
}

output "port" {
  value       = "11211"
  description = "Port"
}

output "config_host" {
  value       = "${module.dns_config.hostname}"
  description = "Config host"
}

output "hosts" {
  value       = "${join(",", null_resource.host.*.triggers.name)}"
  description = "Hosts"
}
