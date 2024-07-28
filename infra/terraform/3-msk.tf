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
  for_each = { for idx, cfg in local.sink_configs : idx => cfg }

  name = replace("${each.value.topic}", "_", "-")
  subnet_ids = module.network.subnet_ids

  security_group_id = module.network.sg_id

  topics              = each.value.topic

  bucket_name = local.data_bucket_name
  region = local.region
  register_name = each.value.registry_name

  key_schema_name = lookup(each.value, "key_schema_name", "${each.value.topic}-key")
  value_schema_name = lookup(each.value, "value_schema_name", "${each.value.topic}-value")

  bootstrap_brokers_tls = module.msk_instance.bootstrap_brokers_tls

  custom_plugin_arn = module.s3_connect_plugin.plugin_arn
  custom_plugin_revision = module.s3_connect_plugin.plugin_latest_revision
}

# Registry
resource "aws_glue_registry" "example" {
  registry_name = local.registry_name
  tags = local.tags
}