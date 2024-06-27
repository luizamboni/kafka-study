# Network
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = merge({},
    var.tags
  )
}

resource "aws_subnet" "subnet" {
  for_each = { for idx, subnet in var.subnet_config : idx => subnet }

  availability_zone = each.value.az
  cidr_block        = each.value.cidr
  vpc_id            = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.name}-private-${each.key}"
  }, var.tags)
}


resource "aws_security_group" "sg" {
  name        = "${var.name}-allow-all"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
      Name = "${var.name}-sg"
    },
    var.tags
  )
}


data "aws_route_tables" "selected" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${var.region}.s3"  # Replace with your AWS region
  vpc_endpoint_type  = "Gateway"

  route_table_ids = data.aws_route_tables.selected.ids

  tags = {
    Name = "s3-endpoint"
  }
}