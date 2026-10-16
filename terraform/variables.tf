variable "aws_region" {
  description = "AWS region for the demo infrastructure."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Short project prefix used in AWS resource names."
  type        = string
  default     = "voting-app"
}

variable "github_owner" {
  description = "GitHub username or organization that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "Repository name, without owner."
  type        = string
}

variable "github_branch" {
  description = "Branch allowed to assume the GitHub Actions role."
  type        = string
  default     = "main"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version supported in the selected AWS region."
  type        = string
  default     = "1.32"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}
