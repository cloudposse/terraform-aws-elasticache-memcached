region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "memcached-test"

instance_type = "cache.t2.micro"

cluster_size = 1

# https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/supported-engine-versions.html
engine_version = "1.5.16"

elasticache_parameter_group_family = "memcached1.5"
