output "eks_cluster_name" {
  description = "Amazon EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Amazon EKS Kubernetes API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL for NationalVote"
  value       = aws_ecr_repository.app.repository_url
}

output "aws_region" {
  description = "AWS region hosting NationalVote"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID for NationalVote"
  value       = aws_vpc.main.id
}

output "worker_node_group_name" {
  description = "EKS managed worker node group name"
  value       = aws_eks_node_group.main.node_group_name
}
