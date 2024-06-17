variable subnet_cidrs {
  type = list(string)
}

variable vpc_cidr {
  type = string
}

variable tags {
    type = map(string)
    default = {}
}

variable name {
    type = string
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = merge({
      Name: var.name
    },
    var.tags
  )
}

data "aws_availability_zones" "azs" {
  state = "available"
}


resource "aws_subnet" "subnet" {
  for_each = { for idx, cidr in var.subnet_cidrs : idx => cidr }

  availability_zone = data.aws_availability_zones.azs.names[each.key % length(data.aws_availability_zones.azs.names)]
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = merge({
      Name = "${var.name}-${each.key + 1}"
    },
    var.tags
  )
}

output vpc_id {
    value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.subnet : subnet.id]
}