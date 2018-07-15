
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_actions | Alarm actions | list | `<list>` | no |
| alarm_cpu_threshold_percent | CPU threshold alarm level | string | `75` | no |
| alarm_memory_threshold_bytes | Alarm memory threshold bytes | string | `10000000` | no |
| apply_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window | string | `true` | no |
| availability_zones | List of Availability Zones where subnets will be created | list | - | yes |
| cluster_size | Cluster size | string | `1` | no |
| engine_version | Engine version | string | `1.4.33` | no |
| instance_type | Elastic cache instance type | string | `t2.micro` | no |
| maintenance_window | Maintenance window | string | `wed:03:00-wed:04:00` | no |
| max_item_size | Max item size | string | `10485760` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | string | - | yes |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | - | yes |
| notification_topic_arn | Notification topic arn | string | `` | no |
| security_groups | AWS security group ids | list | - | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| subnets | AWS subnet ids | list | `<list>` | no |
| vpc_id | VPC ID | string | `` | no |
| zone_id | Route53 DNS Zone id | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| config_host | Config host |
| hosts | Hosts |
| id | Disambiguated ID |
| port | Port |
| security_group_id | Security group id |

