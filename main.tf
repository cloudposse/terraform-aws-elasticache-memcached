locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default.*.name)
  enabled                       = module.this.enabled
  security_group_enabled        = module.this.enabled && var.security_group_enabled
}

resource "null_resource" "cluster_urls" {
  count = local.enabled ? var.cluster_size : 0

  triggers = {
    name = "${replace(
      join("", aws_elasticache_cluster.default.*.cluster_address),
      ".cfg.",
      format(".%04d.", count.index + 1)
    )}:${var.port}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Security Group Resources
#

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "0.3.1"

  use_name_prefix = var.security_group_use_name_prefix
  rules           = var.security_group_rules
  description     = var.security_group_description
  vpc_id          = var.vpc_id

  enabled = local.security_group_enabled
  context = module.this.context
}

#
# ElastiCache Resources
#
resource "aws_elasticache_subnet_group" "default" {
  count      = local.enabled ? 1 : 0
  name       = module.this.id
  subnet_ids = var.subnets
}

resource "aws_elasticache_parameter_group" "default" {
  count  = local.enabled ? 1 : 0
  name   = module.this.id
  family = var.elasticache_parameter_group_family

  parameter {
    name  = "max_item_size"
    value = var.max_item_size
  }
}

resource "aws_elasticache_cluster" "default" {
  count                        = local.enabled ? 1 : 0
  apply_immediately            = var.apply_immediately
  cluster_id                   = module.this.id
  engine                       = "memcached"
  engine_version               = var.engine_version
  node_type                    = var.instance_type
  num_cache_nodes              = var.cluster_size
  parameter_group_name         = join("", aws_elasticache_parameter_group.default.*.name)
  subnet_group_name            = local.elasticache_subnet_group_name
  security_group_ids           = compact(concat(module.security_group.*.id, var.security_groups))
  maintenance_window           = var.maintenance_window
  notification_topic_arn       = var.notification_topic_arn
  port                         = var.port
  az_mode                      = var.az_mode
  availability_zone            = var.availability_zone
  preferred_availability_zones = var.availability_zones
  tags                         = module.this.tags
}

#
# CloudWatch Resources
#
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = local.enabled ? 1 : 0
  alarm_name          = "${module.this.id}-cpu-utilization"
  alarm_description   = "Memcached cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = module.this.id
  }

  alarm_actions = var.alarm_actions
  depends_on    = [aws_elasticache_cluster.default]
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = local.enabled ? 1 : 0
  alarm_name          = "${module.this.id}-freeable-memory"
  alarm_description   = "Memcached cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_bytes

  dimensions = {
    CacheClusterId = module.this.id
  }

  alarm_actions = var.alarm_actions
  depends_on    = [aws_elasticache_cluster.default]
}

module "dns" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.12.2"
  enabled = local.enabled && var.zone_id != "" ? true : false
  ttl     = 60
  zone_id = var.zone_id
  records = [join("", aws_elasticache_cluster.default.*.cluster_address)]

  context = module.this.context
}
