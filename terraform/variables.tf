
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_id" {
  description = "VPC ID for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID with internet access"
  type        = string
}

variable "ubuntu_ami_id" {
  description = "Ubuntu Server 24.04 LTS AMI ID for your region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.xlarge"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Your public IP address followed by /32"
  type        = string
}

variable "app_allowed_cidr" {
  description = "IP range allowed to access the application"
  type        = string
  default     = "0.0.0.0/0"
}
