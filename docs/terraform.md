<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.0 |
| null | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |
| null | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alarm\_actions | Alarm actions | `list(string)` | `[]` | no |
| alarm\_cpu\_threshold\_percent | CPU threshold alarm level | `number` | `75` | no |
| alarm\_memory\_threshold\_bytes | Alarm memory threshold bytes | `number` | `10000000` | no |
| allowed\_cidr\_blocks | List of CIDR blocks that are allowed ingress to the cluster's Security Group created in the module | `list(string)` | `[]` | no |
| allowed\_security\_groups | List of Security Group IDs that are allowed ingress to the cluster's Security Group created in the module | `list(string)` | `[]` | no |
| apply\_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window | `bool` | `true` | no |
| attributes | Additional attributes (\_e.g.\_ "1") | `list(string)` | `[]` | no |
| availability\_zones | List of Availability Zones for the cluster | `list(string)` | n/a | yes |
| cluster\_size | Cluster size | `number` | `1` | no |
| delimiter | Delimiter between `name`, `namespace`, `stage` and `attributes` | `string` | `"-"` | no |
| elasticache\_parameter\_group\_family | ElastiCache parameter group family | `string` | `"memcached1.5"` | no |
| elasticache\_subnet\_group\_name | Subnet group name for the ElastiCache instance | `string` | `""` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| engine\_version | Memcached engine version. For more info, see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/supported-engine-versions.html | `string` | `"1.5.16"` | no |
| existing\_security\_groups | List of existing Security Group IDs to place the cluster into. Set `use_existing_security_groups` to `true` to enable using `existing_security_groups` as Security Groups for the cluster | `list(string)` | `[]` | no |
| instance\_type | Elastic cache instance type | `string` | `"cache.t2.micro"` | no |
| label\_order | The naming order of the id output and Name tag | `list(string)` | `[]` | no |
| maintenance\_window | Maintenance window | `string` | `"wed:03:00-wed:04:00"` | no |
| max\_item\_size | Max item size | `number` | `10485760` | no |
| name | Name of the application | `string` | n/a | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | `string` | `""` | no |
| notification\_topic\_arn | Notification topic arn | `string` | `""` | no |
| port | Memcached port | `number` | `11211` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | `""` | no |
| subnets | AWS subnet ids | `list(string)` | `[]` | no |
| tags | Additional tags (\_e.g.\_ map("BusinessUnit","ABC") | `map(string)` | `{}` | no |
| use\_existing\_security\_groups | Flag to enable/disable creation of Security Group in the module. Set to `true` to disable Security Group creation and provide a list of existing security Group IDs in `existing_security_groups` to place the cluster into | `bool` | `false` | no |
| vpc\_id | VPC ID | `string` | `""` | no |
| zone\_id | Route53 DNS Zone ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_address | Cluster address |
| cluster\_configuration\_endpoint | Cluster configuration endpoint |
| cluster\_id | Cluster ID |
| cluster\_urls | Cluster URLs |
| hostname | Cluster hostname |
| security\_group\_id | Security Group ID |

<!-- markdownlint-restore -->
