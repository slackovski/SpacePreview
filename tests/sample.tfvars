# Terraform variable values — do NOT commit production values to git
aws_region   = "ap-northeast-1"
environment  = "staging"
instance_type = "t3.micro"

db_instance_class = "db.t3.small"
db_name           = "myapp_staging"
db_username       = "app_user"

redis_node_type   = "cache.t3.micro"
redis_num_shards  = 1

tags = {
  Project     = "SpacePreview"
  Environment = "staging"
  ManagedBy   = "Terraform"
}
