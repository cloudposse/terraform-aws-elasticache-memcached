variable "use_existing_security_groups" {
  type        = bool
  description = <<-EOT
    DEPRECATED: Use `create_security_group` instead.
    Historical description: Flag to enable/disable creation of Security Group in the module.
    Set to `true` to disable Security Group creation and provide a list of existing security Group IDs in `existing_security_groups` to place the cluster into.
    Historical default: `false`
    EOT
  default     = null
}

variable "existing_security_groups" {
  type        = list(string)
  default     = []
  description = <<-EOT
    DEPRECATED: Use `associated_security_group_ids` instead.
    Historical description: List of existing Security Group IDs to place the cluster into.
    Set `use_existing_security_groups` to `true` to enable using `existing_security_groups` as Security Groups for the cluster.
    EOT
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = <<-EOT
    DEPRECATED: Use `allowed_security_group_ids` instead.
    EOT
}
