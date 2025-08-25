output "firewall_id" {
  description = "Network Firewall ID"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_arn" {
  description = "Network Firewall ARN"
  value       = aws_networkfirewall_firewall.main.arn
}

output "policy_arn" {
  description = "Network Firewall Policy ARN"
  value       = aws_networkfirewall_firewall_policy.main.arn
}

output "rule_group_arn" {
  description = "Network Firewall Rule Group ARN"
  value       = aws_networkfirewall_rule_group.suricata_rules.arn
}

output "firewall_route_table_id" {
  description = "Firewall route table ID"
  value       = aws_route_table.firewall.id
} 