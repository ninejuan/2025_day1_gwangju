# Hub Private Subnet A → Transit Gateway 라우팅
resource "aws_route" "hub_private_a_to_tgw" {
  route_table_id         = var.hub_private_a_route_table_id
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gateway_id
}

# Hub Private Subnet B → Transit Gateway 라우팅
resource "aws_route" "hub_private_b_to_tgw" {
  route_table_id         = var.hub_private_b_route_table_id
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gateway_id
}

# App Private Subnet A → Transit Gateway 라우팅
resource "aws_route" "app_private_a_to_tgw" {
  route_table_id         = var.app_private_a_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = var.transit_gateway_id
}

# App Private Subnet B → Transit Gateway 라우팅
resource "aws_route" "app_private_b_to_tgw" {
  route_table_id         = var.app_private_b_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = var.transit_gateway_id
}
