resource "null_resource" "write_outputs_to_file" {

    provisioner "local-exec" {

        command = <<EOT
echo "INTERNAL_BROKER_ENDPOINT=${module.msk_instance.bootstrap_brokers_tls}" > env.cloud
echo "GLUE_REGISTRY_NAME=${local.registry_name}" >> env.cloud
echo "SECURITY_PROTOCOL=SSL" >> env.cloud

EOT
    }

    triggers = {
        always_run = "${timestamp()}"
    }

}