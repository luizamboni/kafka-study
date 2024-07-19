resource "null_resource" "write_outputs_to_file" {

    provisioner "local-exec" {

        command = <<EOT
echo "INTERNAL_BROKER_ENDPOINT=${module.msk_instance.bootstrap_brokers_tls}" > env.cloud
echo "GLUE_REGISTRY_NAME=${local.register_name}" >> env.cloud
echo "TOPIC_GLUE_AVRO_EXAMPLE=${local.glyue_avro_example_topic}" >> env.cloud
echo "SECURITY_PROTOCOL=SSL" >> env.cloud

EOT
    }

    triggers = {
        always_run = "${timestamp()}"
    }

}