resource "aws_iam_role" "msk_connect_role" {
  name = "MSKConnectRole-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "msk_connect_policy" {
  name        = "MSKConnectPolicy-${var.name}"
  description = "Policy for MSK Connect to access MSK and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka:*",
          "s3:*",
          "glue:*",
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.msk_connect_role.name
  policy_arn = aws_iam_policy.msk_connect_policy.arn
}


resource "aws_cloudwatch_log_group" "test" {
  name = "msk_connect_${var.name}_logs"
  tags = merge({}, var.tags)
}

resource "aws_mskconnect_connector" "example" {
    name = var.name

    kafkaconnect_version = "2.7.1"

    capacity {
        autoscaling {
            mcu_count        = 1
            min_worker_count = 1
            max_worker_count = 2

            scale_in_policy {
                cpu_utilization_percentage = 20
            }

            scale_out_policy {
                cpu_utilization_percentage = 80
            }
        }
    }

    connector_configuration = jsondecode(
        templatefile("${path.module}/template/connector_config.json.tftpl", {
            topics = var.topics
            tasks = 1
            bucket_name = var.bucket_name
            region = var.region
            register_name = var.register_name

            key_schema_name = var.key_schema_name
            value_schema_name = var.value_schema_name
        })
    )

    kafka_cluster {
        apache_kafka_cluster {
            bootstrap_servers = var.bootstrap_brokers_tls

            vpc {
                security_groups = [var.security_group_id]
                subnets         = var.subnet_ids
            }
        }
    }

    kafka_cluster_client_authentication {
        authentication_type = "NONE"
    }

    kafka_cluster_encryption_in_transit {
        encryption_type = "TLS"
    }

    plugin {
        custom_plugin {
            arn      = var.custom_plugin_arn
            revision = var.custom_plugin_revision
        }
    }

    log_delivery {
        worker_log_delivery {
            cloudwatch_logs {
                enabled = true
                log_group = aws_cloudwatch_log_group.test.name
            }
        }
    }
    service_execution_role_arn = aws_iam_role.msk_connect_role.arn


    timeouts {
      create = "60m"
      update = "2h"
      delete = "30m"
    }
}