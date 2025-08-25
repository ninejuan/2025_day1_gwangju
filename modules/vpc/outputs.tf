output "hub_vpc_id" {
  description = "Hub VPC ID"
  value       = aws_vpc.hub.id
}

output "app_vpc_id" {
  description = "Application VPC ID"
  value       = aws_vpc.app.id
}

output "vpc_ids" {
  description = "All VPC IDs"
  value = {
    hub = aws_vpc.hub.id
    app = aws_vpc.app.id
  }
}

output "hub_internet_gateway_id" {
  description = "Hub Internet Gateway ID"
  value       = aws_internet_gateway.hub.id
}

output "app_internet_gateway_id" {
  description = "App Internet Gateway ID"
  value       = aws_internet_gateway.app.id
}

output "hub_public_subnet_a_id" {
  description = "Hub public subnet A ID"
  value       = aws_subnet.hub_public_a.id
}

output "hub_public_subnet_ids" {
  description = "Hub public subnet IDs"
  value = [
    aws_subnet.hub_public_a.id,
    aws_subnet.hub_public_b.id
  ]
}

output "app_public_subnet_ids" {
  description = "App public subnet IDs"
  value = [
    aws_subnet.app_public_a.id,
    aws_subnet.app_public_b.id
  ]
}

output "hub_private_subnet_ids" {
  description = "Hub private subnet IDs"
  value = [
    aws_subnet.hub_private_a.id,
    aws_subnet.hub_private_b.id
  ]
}

output "hub_firewall_subnet_id" {
  description = "Hub firewall subnet ID"
  value       = aws_subnet.hub_firewall.id
}

output "app_private_subnet_ids" {
  description = "Application private subnet IDs"
  value = [
    aws_subnet.app_private_a.id,
    aws_subnet.app_private_b.id
  ]
}

output "app_data_subnet_ids" {
  description = "Application data subnet IDs"
  value = [
    aws_subnet.app_data_a.id,
    aws_subnet.app_data_b.id
  ]
}

output "subnet_ids" {
  description = "All subnet IDs"
  value = {
    hub_public_a     = aws_subnet.hub_public_a.id
    hub_public_b     = aws_subnet.hub_public_b.id
    hub_private_a    = aws_subnet.hub_private_a.id
    hub_private_b    = aws_subnet.hub_private_b.id
    hub_firewall     = aws_subnet.hub_firewall.id
    app_public_a     = aws_subnet.app_public_a.id
    app_public_b     = aws_subnet.app_public_b.id
    app_private_a    = aws_subnet.app_private_a.id
    app_private_b    = aws_subnet.app_private_b.id
    app_data_a       = aws_subnet.app_data_a.id
    app_data_b       = aws_subnet.app_data_b.id
  }
} 