resource "aws_acm_certificate" "vpn_server" {
  private_key       = file(var.cert_server_key)
  certificate_body  = file(var.cert_server_ctr)
  certificate_chain = file(var.cert_ca)

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({}, var.tags)
}

resource "aws_acm_certificate" "vpn_client" {
  private_key       = file(var.cert_client_key)
  certificate_body  = file(var.cert_client_ctr)
  certificate_chain = file(var.cert_ca)

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({}, var.tags)
}

resource "aws_cloudwatch_log_group" "test" {
  name = "client_vpn_endpoint_logs"
  tags = merge({}, var.tags)
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = "VPN endpoint"
  client_cidr_block = var.client_cidr_block
  split_tunnel = true
  server_certificate_arn = aws_acm_certificate.vpn_server.arn
  security_group_ids = [var.security_group_id]
  vpc_id = var.vpc_id
  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_client.arn
  }

  connection_log_options {
    enabled = true
    cloudwatch_log_group = aws_cloudwatch_log_group.test.name
  }

  tags = merge({}, var.tags)
}


resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  count = length(var.subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id = element(var.subnet_ids, count.index)
  lifecycle {
    ignore_changes = [subnet_id]
  }

  timeouts {
    create = "30m"
    delete = "40m"
  }
}

data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.key
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  for_each             = data.aws_subnet.selected
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr  = each.value.cidr_block
  authorize_all_groups = true

  timeouts {
    create = "40m"
    delete = "40m"
  }
}