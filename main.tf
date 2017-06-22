# Define composite variables for resources
resource "null_resource" "default" {
  triggers = {
    id = "${lower(format("%v-%v-%v", var.namespace, var.stage, var.name))}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "host" {
  count = "${var.cluster_size}"

  triggers = {
    name = "${replace(aws_elasticache_cluster.default.cluster_address, ".cfg.", format(".%04d.", count.index + 1))}:11211"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Security Group Resources
#
resource "aws_security_group" "default" {
  vpc_id = "${var.vpc_id}"
  name   = "${null_resource.default.triggers.id}"

  ingress {
    from_port       = "11211"                    # Memcache
    to_port         = "11211"
    protocol        = "tcp"
    security_groups = ["${var.security_groups}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${null_resource.default.triggers.id}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "${null_resource.default.triggers.id}"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "${null_resource.default.triggers.id}"
  family = "memcached1.4"

  parameter {
    name  = "max_item_size"
    value = "${var.max_item_size}"
  }
}

#
# ElastiCache Resources
#
resource "aws_elasticache_cluster" "default" {
  cluster_id             = "${null_resource.default.triggers.id}"
  engine                 = "memcached"
  engine_version         = "${var.engine_version}"
  node_type              = "${var.instance_type}"
  num_cache_nodes        = "${var.cluster_size}"
  parameter_group_name   = "${aws_elasticache_parameter_group.default.name}"
  subnet_group_name      = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids     = ["${aws_security_group.default.id}"]
  maintenance_window     = "${var.maintenance_window}"
  notification_topic_arn = "${var.notification_topic_arn}"
  port                   = "11211"
  az_mode                = "${var.cluster_size == 1 ? "single-az" : "cross-az" }"
  availability_zones     = ["${slice(var.availability_zones, 0, var.cluster_size)}"]

  tags {
    Name      = "${null_resource.default.triggers.id}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}

#
# CloudWatch Resources
#
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  alarm_name          = "${null_resource.default.triggers.id}-cpu-utilization"
  alarm_description   = "Memcached cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"

  threshold = "${var.alarm_cpu_threshold_percent}"

  dimensions {
    CacheClusterId = "${null_resource.default.triggers.id}"
  }

  alarm_actions = ["${var.alarm_actions}"]
  depends_on    = ["aws_elasticache_cluster.default"]
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  alarm_name          = "${null_resource.default.triggers.id}-freeable-memory"
  alarm_description   = "Memcached cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = "${var.alarm_memory_threshold_bytes}"

  dimensions {
    CacheClusterId = "${null_resource.default.triggers.id}"
  }

  alarm_actions = ["${var.alarm_actions}"]
  depends_on    = ["aws_elasticache_cluster.default"]
}

module "dns" {
  source    = "../hostname"
  namespace = "${var.namespace}"
  name      = "${var.name}"
  stage     = "${var.stage}"
  ttl       = 60
  zone_id   = "${var.zone_id}"
  records   = ["${aws_elasticache_cluster.default.cluster_address}"]
}

module "dns_config" {
  source    = "../hostname"
  namespace = "${var.namespace}"
  name      = "config.${var.name}"
  stage     = "${var.stage}"
  ttl       = 60
  zone_id   = "${var.zone_id}"
  records   = ["${aws_elasticache_cluster.default.configuration_endpoint}"]
}