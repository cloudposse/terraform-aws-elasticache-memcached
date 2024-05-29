locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default[*].name)
  enabled                       = module.this.enabled
}

resource "null_resource" "cluster_urls" {
  count = local.enabled ? var.cluster_size : 0

  triggers = {
    name = "${replace(
      join("", aws_elasticache_cluster.default[*].cluster_address),
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
locals {
  cidr_ingress_rule = (
    length(var.allowed_cidr_blocks) + length(var.allowed_ipv6_cidr_blocks) + length(var.allowed_ipv6_prefix_list_ids)) == 0 ? null : {
    key         = "cidr-ingress"
    type        = "ingress"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks

    allowed_ipv6_cidr_blocks     = var.allowed_ipv6_cidr_blocks
    allowed_ipv6_prefix_list_ids = var.allowed_ipv6_prefix_list_ids

    description = "Allow inbound traffic from CIDR blocks"
  }

  sg_rules = {
    legacy = merge(local.cidr_ingress_rule, {})
    extra  = var.additional_security_group_rules
  }
}

module "aws_security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  enabled = local.create_security_group

  allow_all_egress    = var.allow_all_egress
  security_group_name = var.security_group_name
  rules_map           = local.sg_rules
  rule_matrix = [{
    key                       = "in"
    source_security_group_ids = local.allowed_security_group_ids
    rules = [{
      key         = "in"
      type        = "ingress"
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Selectively allow inbound traffic"
    }]
  }]

  vpc_id = var.vpc_id

  security_group_description = local.security_group_description

  create_before_destroy = var.security_group_create_before_destroy

  security_group_create_timeout = var.security_group_create_timeout
  security_group_delete_timeout = var.security_group_delete_timeout

  context = module.this.context
}

#
# ElastiCache Resources
#
resource "aws_elasticache_subnet_group" "default" {
  count       = local.enabled && var.elasticache_subnet_group_name == "" && length(var.subnets) > 0 ? 1 : 0
  name        = module.this.id
  description = "Elasticache subnet group for ${module.this.id}"
  subnet_ids  = var.subnets
  tags        = module.this.tags
}

resource "aws_elasticache_parameter_group" "default" {
  count  = local.enabled ? 1 : 0
  name   = module.this.id
  family = var.elasticache_parameter_group_family

  dynamic "parameter" {
    for_each = var.elasticache_parameters
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }
}

resource "aws_elasticache_cluster" "default" {
  count                      = local.enabled ? 1 : 0
  apply_immediately          = var.apply_immediately
  cluster_id                 = module.this.id
  engine                     = "memcached"
  engine_version             = var.engine_version
  node_type                  = var.instance_type
  num_cache_nodes            = var.cluster_size
  parameter_group_name       = join("", aws_elasticache_parameter_group.default[*].name)
  transit_encryption_enabled = var.transit_encryption_enabled
  subnet_group_name          = local.elasticache_subnet_group_name
  # It would be nice to remove null or duplicate security group IDs, if there are any, using `compact`,
  # but that causes problems, and having duplicates does not seem to cause problems.
  # See https://github.com/hashicorp/terraform/issues/29799
  security_group_ids           = local.create_security_group ? concat(local.associated_security_group_ids, [module.aws_security_group.id]) : local.associated_security_group_ids
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
  count               = local.enabled && var.cloudwatch_metric_alarms_enabled ? 1 : 0
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
  count               = local.enabled && var.cloudwatch_metric_alarms_enabled ? 1 : 0
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
  source   = "cloudposse/route53-cluster-hostname/aws"
  version  = "0.13.0"
  enabled  = module.this.enabled && length(var.zone_id) > 0 ? true : false
  dns_name = var.dns_subdomain != "" ? var.dns_subdomain : module.this.id
  ttl      = 60
  zone_id  = var.zone_id
  records  = [join("", aws_elasticache_cluster.default[*].cluster_address)]

  context = module.this.context
}
