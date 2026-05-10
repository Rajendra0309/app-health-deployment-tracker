aws_region      = "us-east-1"
cluster_name    = "app-health-tracker-eks"
cluster_version = "1.35"
instance_types  = ["t3.micro"]
desired_size    = 2
min_size        = 2
max_size        = 3