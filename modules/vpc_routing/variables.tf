variable "transit_gateway_id" {
  description = "Transit Gateway ID"
  type        = string
}

variable "hub_private_a_route_table_id" {
  description = "Hub Private A Route Table ID"
  type        = string
}

variable "hub_private_b_route_table_id" {
  description = "Hub Private B Route Table ID"
  type        = string
}

variable "app_private_a_route_table_id" {
  description = "App Private A Route Table ID"
  type        = string
}

variable "app_private_b_route_table_id" {
  description = "App Private B Route Table ID"
  type        = string
}
