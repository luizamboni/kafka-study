resource "aws_kms_key" "kms" {
  description = "example"
  tags = merge({}, var.tags)
}

resource "aws_cloudwatch_log_group" "test" {
  name = "msk_broker_logs"
  tags = merge({}, var.tags)
}


resource "aws_msk_configuration" "example" {
  kafka_versions = ["3.2.0"]
  name           = "example"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "example" {
  cluster_name           = var.name
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type = "kafka.t3.small"
    client_subnets = var.subnet_ids
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    security_groups = [var.security_group_id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  # client_authentication  {
  #   sasl {
  #     iam   = true
  #     # scram = true
  #   }
  # }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
    }
  }

  tags = merge({}, var.tags)
}

