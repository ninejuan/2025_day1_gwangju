output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks.id
}

output "node_group_security_group_id" {
  description = "EKS node group security group ID"
  value       = aws_security_group.eks.id
}

output "cluster_iam_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.eks_cluster.arn
}

output "node_group_iam_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = aws_iam_role.eks_node_group.arn
}

output "cluster_kms_key_arn" {
  description = "EKS cluster KMS key ARN"
  value       = aws_kms_key.eks.arn
}

 