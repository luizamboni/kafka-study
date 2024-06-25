## MSK
module msk_instance {
  source = "./modules/msk"
  name  = "example"
  tags = {
    experiment = "Connect"
  }

  security_group_id = module.network.sg_id
  subnet_ids = module.network.subnet_ids
  vpc_id = module.network.vpc_id
}

resource "aws_s3_bucket" "bucket" {
  bucket = "connector-configs"
}

### MSK Connect
module "s3_connect_plugin" {
  source = "./modules/connector_plugin"
  bucket_id = aws_s3_bucket.bucket.id
  name = "s3-connect-plugin"
  source_file = "${path.module}/msk_connect_plugins/lib.zip"
}

module "s3_connect-avro-to-parquet-example" {
  source = "./modules/s3_connector"
  name = "test-connector"
  subnet_ids = module.network.subnet_ids

  security_group_id = module.network.sg_id

  topics = "glue-registry-avro-schema"
  bucket_name = local.data_bucket_name
  region = local.region
  register_name = "kafka-study"
  key_schema_name = "glue-registry-avro-schema-key"
  value_schema_name = "glue-registry-avro-schema-value"

  bootstrap_brokers_tls = module.msk_instance.bootstrap_brokers_tls

  custom_plugin_arn = module.s3_connect_plugin.plugin_arn
  custom_plugin_revision = module.s3_connect_plugin.plugin_latest_revision
}