terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  project = "seed infra"
  name = "seed"
  region = "us-east-1"

  
  database_name = local.name
  registry_name = local.name
  data_bucket_name = "glue-database-${local.name}.${local.account_id}.${local.region}.${local.database_name}"


  sink_configs = [
    {
      topic = "user_login-v1"
      registry_name = local.registry_name
    },
    {
      topic = "user_login-v2"
      registry_name = local.registry_name
    },
    {
      topic = "user_login-v3"
      registry_name = local.registry_name
    },
  ]

  tags = {
    Project = local.project
    Name = local.name
  }

  # vpc_cidr = "192.168.0.0/22"

  # subnet_config = [
  #   { cidr = "192.168.0.0/24", az = "us-east-1a" },
  #   { cidr = "192.168.1.0/24", az = "us-east-1b" },
  #   # { cidr = "192.168.2.0/24", az = "us-east-1c" }
  # ]
  
  # vpn_client_cidr = "10.1.0.0/16"

  # # GPT suggest to me to avoid conflicts in my machine due
  # ## my ifconfig output
  vpc_cidr = "10.0.0.0/16"

  # Updated subnet configurations to avoid conflict
  subnet_config = [
    { cidr = "10.0.1.0/24", az = "us-east-1a" },
    { cidr = "10.0.2.0/24", az = "us-east-1b" },
    # { cidr = "10.0.3.0/24", az = "us-east-1c" }
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