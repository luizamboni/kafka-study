module "vpn_endpoint" {
  source = "./modules/vpn_endpoint"

  client_cidr_block =  local.vpn_client_cidr

  vpc_id = aws_vpc.vpc.id
  security_group_id = aws_security_group.sg.id
  subnet_ids = [
      aws_subnet.subnet_az1.id,
      aws_subnet.subnet_az2.id,
      aws_subnet.subnet_az3.id,
  ]
  cert_server_key = "${path.module}/keys/certs/server.key"
  cert_server_ctr = "${path.module}/keys/certs/server.crt"
  cert_client_key = "${path.module}/keys/certs/zamboni.4development.net.key"
  cert_client_ctr = "${path.module}/keys/certs/zamboni.4development.net.crt"
  cert_ca         = "${path.module}/keys/certs/ca.crt"

  tags = merge({}, local.tags)
}
