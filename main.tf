locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default.*.name)
  enabled                       = module.this.enabled
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

resource "aws_security_group" "default" {
  count  = local.enabled && var.use_existing_security_groups == false ? 1 : 0
  vpc_id = var.vpc_id
  name   = module.this.id
  tags   = module.this.tags
}

resource "aws_security_group_rule" "egress" {
  count             = local.enabled && var.use_existing_security_groups == false ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = local.enabled && var.use_existing_security_groups == false ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = local.enabled && var.use_existing_security_groups == false && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
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
  security_group_ids           = var.use_existing_security_groups ? var.existing_security_groups : [join("", aws_security_group.default.*.id)]
  maintenance_window           = var.maintenance_window
  notification_topic_arn       = var.notification_topic_arn
  port                         = var.port
  az_mode                      = var.cluster_size == 1 ? "single-az" : "cross-az"
  preferred_availability_zones = slice(var.availability_zones, 0, var.cluster_size)
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
  version = "0.10.0"
  enabled = local.enabled && var.zone_id != "" ? true : false
  ttl     = 60
  zone_id = var.zone_id
  records = [join("", aws_elasticache_cluster.default.*.cluster_address)]

  context = module.this.context
}
