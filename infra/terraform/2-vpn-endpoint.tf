module "vpn_endpoint" {
  source = "./modules/vpn_endpoint"

  client_cidr_block =  local.vpn_client_cidr

  vpc_id = module.network.vpc_id
  security_group_id = module.network.sg_id
  subnet_ids = module.network.subnet_ids

  cert_server_key = "${path.module}/keys/certs/server.key"
  cert_server_ctr = "${path.module}/keys/certs/server.crt"
  cert_client_key = "${path.module}/keys/certs/client.key"
  cert_client_ctr = "${path.module}/keys/certs/client.crt"
  cert_ca         = "${path.module}/keys/certs/ca.crt"

  tags = merge({}, local.tags)
}
