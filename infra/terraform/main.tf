terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  project = "msk-example"
  name = "msk-example"
  tags = {
    Project = local.project
    Name = local.name
  }

  vpc_cidr = "192.168.0.0/22"
  subnet_cidrs = [ 
    "192.168.0.0/24", 
    "192.168.1.0/24", 
    "192.168.2.0/24" 
  ]
  vpn_client_cidr = "10.1.0.0/16"
}




#### Internet Gateway
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id
#   tags = merge(
#     {},
#     local.tags
#   )
# }

# resource "aws_route_table" "rt" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = merge(
#     {},
#     local.tags
#   )
# }

# resource "aws_route_table_association" "a" {
#   count     = length(data.aws_availability_zones.azs.names)
#   subnet_id = element([aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id, aws_subnet.subnet_az3.id], count.index)
#   route_table_id = aws_route_table.rt.id
# }
####