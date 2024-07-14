resource "null_resource" "install_awscli" {
  provisioner "local-exec" {
    command     = "apk add --no-cache bash py-pip jq aws-cli"
    interpreter = ["/bin/sh", "-c"]
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    module.vpn_endpoint,
  ]
}

resource "null_resource" "get_vpn_endpoint_config" {
  provisioner "local-exec" {

    command = <<EOT
    aws ec2 export-client-vpn-client-configuration \
    --client-vpn-endpoint-id ${module.vpn_endpoint.id} \
    --output text > /workspace/keys/vpn-config.ovpn && \
    echo "<cert>" >> /workspace/keys/vpn-config.ovpn && \
    cat /workspace/keys/certs/client.crt >> /workspace/keys/vpn-config.ovpn && \
    echo "</cert>" >> /workspace/keys/vpn-config.ovpn && \
    echo "<key>" >> /workspace/keys/vpn-config.ovpn && \
    cat /workspace/keys/certs/client.key >> /workspace/keys/vpn-config.ovpn && \
    echo "</key>" >> /workspace/keys/vpn-config.ovpn
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    null_resource.install_awscli,
    module.vpn_endpoint,
  ]
}