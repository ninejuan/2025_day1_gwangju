output "external_nlb_arn" {
  description = "External NLB ARN"
  value       = aws_lb.external_nlb.arn
}

output "external_nlb_dns_name" {
  description = "External NLB DNS name"
  value       = aws_lb.external_nlb.dns_name
}

output "internal_nlb_arn" {
  description = "Internal NLB ARN"
  value       = aws_lb.internal_nlb.arn
}

output "internal_nlb_dns_name" {
  description = "Internal NLB DNS name"
  value       = aws_lb.internal_nlb.dns_name
}

output "internal_alb_arn" {
  description = "Internal ALB ARN"
  value       = aws_lb.internal_alb.arn
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = aws_lb.internal_alb.dns_name
}

output "argo_external_nlb_arn" {
  description = "ArgoCD External NLB ARN"
  value       = aws_lb.argo_external_nlb.arn
}

output "argo_external_nlb_dns_name" {
  description = "ArgoCD External NLB DNS name"
  value       = aws_lb.argo_external_nlb.dns_name
}

output "argo_internal_nlb_arn" {
  description = "ArgoCD Internal NLB ARN"
  value       = aws_lb.argo_internal_nlb.arn
}

output "argo_internal_nlb_dns_name" {
  description = "ArgoCD Internal NLB DNS name"
  value       = aws_lb.argo_internal_nlb.dns_name
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "external_nlb_target_group_arn" {
  description = "External NLB target group ARN"
  value       = aws_lb_target_group.external_nlb.arn
}

output "internal_nlb_target_group_arn" {
  description = "Internal NLB target group ARN"
  value       = aws_lb_target_group.internal_nlb.arn
}

output "internal_alb_target_group_arn" {
  description = "Internal ALB target group ARN"
  value       = aws_lb_target_group.internal_alb.arn
}

output "argo_external_nlb_target_group_arn" {
  description = "ArgoCD External NLB target group ARN"
  value       = aws_lb_target_group.argo_external_nlb.arn
}

output "argo_internal_nlb_target_group_arn" {
  description = "ArgoCD Internal NLB target group ARN"
  value       = aws_lb_target_group.argo_internal_nlb.arn
} 