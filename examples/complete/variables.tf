variable "region" {
  type        = string
  description = "AWS region"
}

variable "az_mode" {
  type        = string
  default     = "single-az"
  description = "Enable or disable multiple AZs, eg: single-az or cross-az"
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

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 DNS Zone ID"
}

variable "elasticache_parameter_group_family" {
  type        = string
  description = "ElastiCache parameter group family"
  default     = "memcached1.5"
}
