output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "hub_attachment_id" {
  description = "Hub VPC Transit Gateway attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.hub.id
}

output "app_attachment_id" {
  description = "Application VPC Transit Gateway attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.app.id
}

output "hub_route_table_id" {
  description = "Hub Transit Gateway route table ID"
  value       = aws_ec2_transit_gateway_route_table.hub.id
}

output "app_route_table_id" {
  description = "Application Transit Gateway route table ID"
  value       = aws_ec2_transit_gateway_route_table.app.id
}
