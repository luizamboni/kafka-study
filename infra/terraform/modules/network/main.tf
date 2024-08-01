# Network
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

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

resource "aws_vpc_endpoint" "glue" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${var.region}.glue"  # Replace with your AWS region
  vpc_endpoint_type  = "Interface"

  security_group_ids = [
    aws_security_group.sg.id,
  ]

  subnet_ids = [for subnet in aws_subnet.subnet : subnet.id]

  private_dns_enabled = true

  tags = {
    Name = "glue-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [for subnet in aws_subnet.subnet : subnet.id]
  security_group_ids = [aws_security_group.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [for subnet in aws_subnet.subnet : subnet.id]
  security_group_ids = [aws_security_group.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for subnet in aws_subnet.subnet : subnet.id]
  security_group_ids = [aws_security_group.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "cloudwatch-endpoint"
  }
}

resource "aws_vpc_endpoint" "athena" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.athena"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for subnet in aws_subnet.subnet : subnet.id]
  security_group_ids = [aws_security_group.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "athena-endpoint"
  }
}