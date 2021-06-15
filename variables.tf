variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID"
}

variable "max_item_size" {
  type        = number
  default     = 10485760
  description = "Max item size"
}

variable "subnets" {
  type        = list(string)
  default     = []
  description = "AWS subnet ids"
}

variable "maintenance_window" {
  type        = string
  default     = "wed:03:00-wed:04:00"
  description = "Maintenance window"
}

variable "cluster_size" {
  type        = number
  default     = 1
  description = "Cluster size"
}

variable "instance_type" {
  type        = string
  default     = "cache.t2.micro"
  description = "Elastic cache instance type"
}

variable "engine_version" {
  type        = string
  default     = "1.5.16"
  description = "Memcached engine version. For more info, see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/supported-engine-versions.html"
}

variable "notification_topic_arn" {
  type        = string
  default     = ""
  description = "Notification topic arn"
}

variable "alarm_cpu_threshold_percent" {
  type        = number
  default     = 75
  description = "CPU threshold alarm level"
}

variable "alarm_memory_threshold_bytes" {
  type        = number
  default     = 10000000 # 10MB
  description = "Alarm memory threshold bytes"
}

variable "alarm_actions" {
  type        = list(string)
  default     = []
  description = "Alarm actions"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
}

variable "availability_zone" {
  type        = string
  default     = ""
  description = "The Availability Zone of the cluster. az_mode must be set to single-az when used."
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "List of Availability Zones for the cluster. az_mode must be set to cross-az when used."
}

variable "az_mode" {
  type        = string
  default     = "single-az"
  description = "Enable or disable multiple AZs, eg: single-az or cross-az"
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 DNS Zone ID"
}

variable "port" {
  type        = number
  default     = 11211
  description = "Memcached port"
}

variable "security_group_enabled" {
  type        = bool
  description = "Whether to create default Security Group for ElastiCache."
  default     = true
}

variable "security_group_description" {
  type        = string
  default     = "ElastiCache Security Group"
  description = "The Security Group description."
}

variable "security_group_use_name_prefix" {
  type        = bool
  default     = false
  description = "Whether to create a default Security Group with unique name beginning with the normalized prefix."
}

variable "security_group_rules" {
  type = list(any)
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
  description = <<-EOT
    A list of maps of Security Group rules. 
    The values of map is fully complated with `aws_security_group_rule` resource. 
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule .
  EOT
}

variable "security_groups" {
  description = "A list of Security Group IDs to associate with ElastiCache."
  type        = list(string)
  default     = []
}

variable "elasticache_subnet_group_name" {
  type        = string
  description = "Subnet group name for the ElastiCache instance"
  default     = ""
}

variable "elasticache_parameter_group_family" {
  type        = string
  description = "ElastiCache parameter group family"
  default     = "memcached1.5"
}
