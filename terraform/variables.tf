variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  default     = "app-health-tracker-eks"
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  default     = "1.35"
  description = "Kubernetes version"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "EC2 instance types for worker nodes"
}

variable "desired_size" {
  type        = number
  default     = 2
  description = "Desired number of worker nodes"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of worker nodes"
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum number of worker nodes"
}