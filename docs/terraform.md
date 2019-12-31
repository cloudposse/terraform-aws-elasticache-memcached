## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_actions | Alarm actions | list(string) | `<list>` | no |
| alarm_cpu_threshold_percent | CPU threshold alarm level | number | `75` | no |
| alarm_memory_threshold_bytes | Alarm memory threshold bytes | number | `10000000` | no |
| allowed_cidr_blocks | List of CIDR blocks that are allowed ingress to the cluster's Security Group created in the module | list(string) | `<list>` | no |
| allowed_security_groups | List of Security Group IDs that are allowed ingress to the cluster's Security Group created in the module | list(string) | `<list>` | no |
| apply_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window | bool | `true` | no |
| attributes | Additional attributes (_e.g._ "1") | list(string) | `<list>` | no |
| availability_zones | List of Availability Zones for the cluster | list(string) | - | yes |
| cluster_size | Cluster size | number | `1` | no |
| delimiter | Delimiter between `name`, `namespace`, `stage` and `attributes` | string | `-` | no |
| elasticache_parameter_group_family | ElastiCache parameter group family | string | `memcached1.5` | no |
| elasticache_subnet_group_name | Subnet group name for the ElastiCache instance | string | `` | no |
| enabled | Set to false to prevent the module from creating any resources | bool | `true` | no |
| engine_version | Memcached engine version. For more info, see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/supported-engine-versions.html | string | `1.5.16` | no |
| existing_security_groups | List of existing Security Group IDs to place the cluster into. Set `use_existing_security_groups` to `true` to enable using `existing_security_groups` as Security Groups for the cluster | list(string) | `<list>` | no |
| instance_type | Elastic cache instance type | string | `cache.t2.micro` | no |
| maintenance_window | Maintenance window | string | `wed:03:00-wed:04:00` | no |
| max_item_size | Max item size | number | `10485760` | no |
| name | Name of the application | string | - | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | string | `` | no |
| notification_topic_arn | Notification topic arn | string | `` | no |
| port | Memcached port | number | `11211` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |
| subnets | AWS subnet ids | list(string) | `<list>` | no |
| tags | Additional tags (_e.g._ map("BusinessUnit","ABC") | map(string) | `<map>` | no |
| use_existing_security_groups | Flag to enable/disable creation of Security Group in the module. Set to `true` to disable Security Group creation and provide a list of existing security Group IDs in `existing_security_groups` to place the cluster into | bool | `false` | no |
| vpc_id | VPC ID | string | `` | no |
| zone_id | Route53 DNS Zone ID | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_address | Cluster address |
| cluster_configuration_endpoint | Cluster configuration endpoint |
| cluster_id | Cluster ID |
| cluster_urls | Cluster URLs |
| hostname | Cluster hostname |
| security_group_id | Security Group ID |

