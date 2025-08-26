output "hub_vpc_id" {
  description = "Hub VPC ID"
  value       = aws_vpc.hub.id
}

output "app_vpc_id" {
  description = "App VPC ID"
  value       = aws_vpc.app.id
}

output "hub_public_subnet_a_id" {
  description = "Hub public subnet A ID"
  value       = aws_subnet.hub_public_a.id
}

output "hub_public_subnet_ids" {
  description = "Hub public subnet IDs"
  value       = [aws_subnet.hub_public_a.id, aws_subnet.hub_public_b.id]
}

output "hub_private_subnet_ids" {
  description = "Hub private subnet IDs"
  value       = [aws_subnet.hub_private_a.id, aws_subnet.hub_private_b.id]
}

output "hub_firewall_subnet_id" {
  description = "Hub firewall subnet ID"
  value       = aws_subnet.hub_firewall.id
}

output "app_private_subnet_ids" {
  description = "App private subnet IDs"
  value       = [aws_subnet.app_private_a.id, aws_subnet.app_private_b.id]
}

output "app_data_subnet_ids" {
  description = "App data subnet IDs"
  value       = [aws_subnet.app_data_a.id, aws_subnet.app_data_b.id]
}

output "app_public_subnet_ids" {
  description = "App public subnet IDs"
  value       = [aws_subnet.app_public_a.id, aws_subnet.app_public_b.id]
}

output "hub_internet_gateway_id" {
  description = "Hub Internet Gateway ID"
  value       = aws_internet_gateway.hub.id
}

output "app_internet_gateway_id" {
  description = "App Internet Gateway ID"
  value       = aws_internet_gateway.app.id
}

# Route Table ID outputs
output "hub_private_a_route_table_id" {
  description = "Hub Private A Route Table ID"
  value       = aws_route_table.hub_private_a.id
}

output "hub_private_b_route_table_id" {
  description = "Hub Private B Route Table ID"
  value       = aws_route_table.hub_private_b.id
}

output "app_private_a_route_table_id" {
  description = "App Private A Route Table ID"
  value       = aws_route_table.app_private_a.id
}

output "app_private_b_route_table_id" {
  description = "App Private B Route Table ID"
  value       = aws_route_table.app_private_b.id
} 