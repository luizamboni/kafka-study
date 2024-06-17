
# Network
resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  tags = merge({},
    local.tags
  )
}

data "aws_availability_zones" "azs" {
  state = "available"
}


resource "aws_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block = local.subnet_cidrs[0]
  vpc_id = aws_vpc.vpc.id
  tags = merge({
      Name = "${local.name}-private-0"
    },
    local.tags
  )
}


resource "aws_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block = local.subnet_cidrs[1]
  vpc_id = aws_vpc.vpc.id
  tags = merge({
      Name = "${local.name}-private-1"
    },
    local.tags
  )
}


resource "aws_subnet" "subnet_az3" {
  availability_zone = data.aws_availability_zones.azs.names[2]
  cidr_block = local.subnet_cidrs[2]
  vpc_id = aws_vpc.vpc.id
  tags = merge({
      Name = "${local.name}-private-2"
    },
    local.tags
  )
}


resource "aws_security_group" "sg" {
  name        = "${local.name}-allow-all"

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
      Name = "${local.name}-sg"
    },
    local.tags
  )
}