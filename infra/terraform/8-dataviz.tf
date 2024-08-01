module "metabase_registry" {
    source = "./modules/ecr_repo"
    name = "metabase"
}


module "metabase" {
    source = "./modules/ecs_service"

    name = "metabase"
    image = var.metabase_image
    cluster_id = aws_ecs_cluster.fargate_cluster.id
    subnet_ids = module.network.subnet_ids
    security_group_id = module.network.sg_id
    vpc_id = module.network.vpc_id
    internal = true
    container_port = 3000
    region = local.region

    memory = "2048"

    health_check = "/"

    environment_variables = {

    }

    tags = local.tags

    depends_on = [
        module.metabase_registry
    ]

    optional_policy_json = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Athena",
        "Effect": "Allow",
        "Action": [
          "athena:BatchGetNamedQuery",
          "athena:BatchGetQueryExecution",
          "athena:GetNamedQuery",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetQueryResultsStream",
          "athena:GetWorkGroup",
          "athena:ListDatabases",
          "athena:ListDataCatalogs",
          "athena:ListNamedQueries",
          "athena:ListQueryExecutions",
          "athena:ListTagsForResource",
          "athena:ListWorkGroups",
          "athena:ListTableMetadata",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
          "athena:CreatePreparedStatement",
          "athena:DeletePreparedStatement",
          "athena:GetPreparedStatement"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Glue",
        "Effect": "Allow",
        "Action": [
          "glue:BatchGetPartition",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetTableVersion",
          "glue:GetTableVersions"
        ],
        "Resource": "*"
      },
      {
        "Sid": "S3ReadAccess",
        "Effect": "Allow",
        "Action": ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"],
        "Resource": [
          "arn:aws:s3:::confluent-kafka-connect-s3-study",
          "arn:aws:s3:::confluent-kafka-connect-s3-study/*",
          "arn:aws:s3:::${local.data_bucket_name}",
          "arn:aws:s3:::${local.data_bucket_name}/*"
        ]
      },
      {
        "Sid": "AthenaResultsBucket",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource": [
            "arn:aws:s3:::athena-query-results-${local.account_id}", 
            "arn:aws:s3:::athena-query-results-${local.account_id}/*"
        ]
      }
    ]
}
EOT
}