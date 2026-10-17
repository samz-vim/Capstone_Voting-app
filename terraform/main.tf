# Find the default VPC in the selected AWS region.
data "aws_vpc" "default" {
  default = true
}

# Find subnets belonging to the default VPC.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Find the latest official Ubuntu 24.04 LTS AMI.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for the voting application.
resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Security group for NationalVote EC2"
  vpc_id      = data.aws_vpc.default.id

  # SSH access restricted to your public IP.
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Flask application port for initial testing.
  ingress {
    description = "Voting application"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permit outbound connections for package downloads
  # and application operations.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# EC2 instance for NationalVote.
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ubuntu
  EOF

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}
