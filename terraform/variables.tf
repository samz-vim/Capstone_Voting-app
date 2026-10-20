variable "aws_region" {
  description = "AWS region for NationalVote infrastructure"
  type        = string
  default     = "eu-west-1"
}


variable "availability_zone" {
  description = "AWS Availability Zone for the public subnets"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name prefix for NationalVote resources"
  type        = string
  default     = "nationalvote"
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_node_count" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges allowed to reach the EKS public API endpoint"
  type        = list(string)

  # Suitable for initial connectivity testing only.
  # Restrict this to trusted addresses for a production deployment.
  default = ["0.0.0.0/0"]
}
