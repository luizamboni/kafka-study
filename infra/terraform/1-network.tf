
module "network" {
  source = "./modules/network"
  name = local.name
  vpc_cidr = local.vpc_cidr
  subnet_config = local.subnet_config
  tags = local.tags
}