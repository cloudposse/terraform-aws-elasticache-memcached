variable "name" {
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
}

variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "security_groups" {
  type        = "list"
  description = "AWS security group ids"
}

variable "vpc_id" {
  default     = ""
  description = "VPC ID"
}

variable "max_item_size" {
  default     = "10485760"
  description = "Max item size"
}

variable "subnets" {
  type        = "list"
  default     = []
  description = "AWS subnet ids"
}

variable "maintenance_window" {
  default     = "wed:03:00-wed:04:00"
  description = "Maintenance window"
}

variable "cluster_size" {
  default     = "1"
  description = "Cluster size"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Elastic cache instance type"
}

variable "engine_version" {
  default     = "1.4.33"
  description = "Engine version"
}

variable "notification_topic_arn" {
  default     = ""
  description = "Notification topic arn"
}

variable "alarm_cpu_threshold_percent" {
  default     = "75"
  description = "CPU threshold alarm level"
}

variable "alarm_memory_threshold_bytes" {
  # 10MB
  default     = "10000000"
  description = "Alarm memory threshold bytes"
}

variable "alarm_actions" {
  type        = "list"
  default     = []
  description = "Alarm actions"
}

variable "apply_immediately" {
  default     = "true"
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
}

variable "availability_zones" {
  type        = "list"
  description = "List of Availability Zones where subnets will be created"
}

variable "zone_id" {
  default     = ""
  description = "Route53 DNS Zone id"
}
