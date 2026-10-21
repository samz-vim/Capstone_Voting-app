resource "aws_security_group" "nationalvote" {
  name        = "nationalvote-k8s-sg"
  description = "Access for NationalVote Kubernetes"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NationalVote NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = [var.app_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "nationalvote-k8s-sg"
    Project = "NationalVote"
  }
}

resource "aws_instance" "nationalvote" {
  ami                         = var.ubuntu_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.nationalvote.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data                   = file("${path.module}/bootstrap.sh")
  user_data_replace_on_change = true

  tags = {
    Name    = "NationalVote-Kubernetes"
    Project = "NationalVote"
  }
}


resource "aws_eip" "nationalvote" {
  domain = "vpc"

  tags = {
    Name = "nationalvote-elastic-ip"
  }
}

resource "aws_eip_association" "nationalvote" {
  instance_id   = aws_instance.nationalvote.id
  allocation_id = aws_eip.nationalvote.id
}

