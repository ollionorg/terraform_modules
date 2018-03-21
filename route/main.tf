
# Variables
# ========================================

variable "vpc_id" { 
  description = "The ID for the VPC to launch the subnets in" 
}

variable "routes" {
  type        = "list"
  description = "A list of key-value pairs to configure routes. Key values should match the parameter names to the aws_route resource block."
}


# Data Sources
# ========================================
data "aws_route_table" "current" {
  vpc_id = "${var.vpc_id}"
}


# Resources
# =======================================

resource "aws_route" "route" {
  count = "${length(var.routes)}"

  route_table_id              = "${data.aws_route_table.current.id}"
  destination_cidr_block      = "${lookup(element(var.routes,count.index), "destination_cidr_block", "")}"
  destination_ipv6_cidr_block = "${lookup(element(var.routes,count.index), "destination_ipv6_cidr_block", "")}"
  vpc_peering_connection_id   = "${lookup(element(var.routes,count.index), "vpc_peering_connection_id", "")}"
  egress_only_gateway_id      = "${lookup(element(var.routes,count.index), "egress_only_gateway_id", "")}"
  gateway_id                  = "${lookup(element(var.routes,count.index), "gateway_id", "")}"
  network_interface_id        = "${lookup(element(var.routes,count.index), "network_interface_id", "")}"
  nat_gateway_id              = "${lookup(element(var.routes,count.index), "nat_gateway_id", "")}"
  instance_id                 = "${lookup(element(var.routes,count.index), "instance_id", "")}"
  network_interface_id        = "${lookup(element(var.routes,count.index), "network_interface_id", "")}"
}
