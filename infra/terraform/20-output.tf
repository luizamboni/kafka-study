resource "null_resource" "write_outputs_to_file" {

    provisioner "local-exec" {

        command = <<EOT
echo "INTERNAL_BROKER_ENDPOINT=${module.msk_instance.bootstrap_brokers_tls}" > cloud.env
echo "GLUE_REGISTRY_NAME=${local.register_name}" >> cloud.env
echo "TOPIC_GLUE_AVRO_EXAMPLE=${local.glyue_avro_example_topic}" >> cloud.env
echo "SECURITY_PROTOCOL=SSL" >> cloud.env

EOT
    }

    triggers = {
        always_run = "${timestamp()}"
    }

}