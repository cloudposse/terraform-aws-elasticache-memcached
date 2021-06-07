module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.22.1"
  enabled    = var.enabled
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "null_resource" "cluster_urls" {
  count = var.enabled ? var.cluster_size : 0

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

resource "aws_security_group" "default" {
  count  = var.enabled && var.use_existing_security_groups == false ? 1 : 0
  vpc_id = var.vpc_id
  name   = module.label.id
  tags   = module.label.tags
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled && var.use_existing_security_groups == false ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled && var.use_existing_security_groups == false ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && var.use_existing_security_groups == false && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}

#
# ElastiCache Resources
#
resource "aws_elasticache_subnet_group" "default" {
  count      = var.enabled && var.elasticache_subnet_group_name == "" ? 1 : 0
  name       = module.label.id
  subnet_ids = var.subnets
}

resource "aws_elasticache_parameter_group" "default" {
  count  = var.enabled && !var.use_existing_parameter_group ? 1 : 0
  name   = module.label.id
  family = var.elasticache_parameter_group_family
  tags   = module.label.tags

  parameter {
    name  = "max_item_size"
    value = var.max_item_size
  }
}

locals {
  elasticache_subnet_group_name    = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default.*.name)
  elasticache_parameter_group_name = var.use_existing_parameter_group ? var.elasticache_parameter_group_name : join("", aws_elasticache_parameter_group.default.*.name)
}

resource "aws_elasticache_cluster" "default" {
  count                        = var.enabled ? 1 : 0
  cluster_id                   = module.label.id
  engine                       = "memcached"
  engine_version               = var.engine_version
  node_type                    = var.instance_type
  num_cache_nodes              = var.cluster_size
  parameter_group_name         = local.elasticache_parameter_group_name
  subnet_group_name            = local.elasticache_subnet_group_name
  security_group_ids           = var.use_existing_security_groups ? var.existing_security_groups : [join("", aws_security_group.default.*.id)]
  maintenance_window           = var.maintenance_window
  notification_topic_arn       = var.notification_topic_arn
  port                         = var.port
  az_mode                      = var.cluster_size == 1 ? "single-az" : "cross-az"
  preferred_availability_zones = [for i in range(var.cluster_size) : element(var.availability_zones, i)]
  tags                         = module.label.tags

  lifecycle {
    ignore_changes = [
      preferred_availability_zones, # Ignore this because drift detection is not supported an TF will show a perpetual difference.
    ]
  }
}

#
# CloudWatch Resources
#
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${module.label.id}-cpu-utilization"
  alarm_description   = "Memcached cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = module.label.id
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  depends_on                = [aws_elasticache_cluster.default]
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${module.label.id}-freeable-memory"
  alarm_description   = "Memcached cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_bytes

  dimensions = {
    CacheClusterId = module.label.id
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  depends_on                = [aws_elasticache_cluster.default]
}

module "dns" {
  source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.12.0"
  enabled = var.enabled && var.zone_id != "" ? true : false
  name    = var.name
  ttl     = 60
  zone_id = var.zone_id
  records = [join("", aws_elasticache_cluster.default.*.cluster_address)]
}
