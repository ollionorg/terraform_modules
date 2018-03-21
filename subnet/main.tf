
# Data Sources
# ========================================
data "aws_region" "current" {}



# Variables
# ========================================

variable "vpc_id" { 
  description = "The ID for the VPC to launch the subnets in" 
}

variable "availability_zones" {
  type        = "list"
  description = "A list of availability zones to launch the subnets in"
}

variable "subnets" {
  type        = "map"
  description = "A map of subnet names to subnet cidr block pairs"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "An optional map of tags to apply to the created subnet resources, in addition to the subnet name"
}


# Resources
# =======================================

resource "aws_subnet" "subnet" {
  count = "${length(var.subnets)}"

  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(values(var.subnets), count.index)}"
  availability_zone = "${data.aws_region.current.name}${element(var.availability_zones, count.index)}"

  lifecycle {
    create_before_destroy = true 
  }

  tags = "${merge(var.tags,map("Name",element(keys(var.subnets), count.index)))}"
}


# Outputs
# =======================================
output ids   { value = "${join(",", aws_subnet.subnets.*.id)}" }
output names { value = "${join(",", aws_subnet.subnets.*.tags.Name)}" }
