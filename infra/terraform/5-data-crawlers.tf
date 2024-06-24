resource "aws_iam_policy" "s3_access" {
  name = "policy-s3_access-${local.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow",
            Action = [
                "glue:*",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketAcl",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeRouteTables",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "iam:ListRolePolicies",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "cloudwatch:PutMetricData"
            ],
            Resource = [
                "*"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "s3:GetObject",
                # "s3:PutObject",
                # "s3:DeleteObject"
            ],
            Resource = [
                "arn:aws:s3:::${local.data_bucket_name}/*",
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "s3:GetObject"
            ],
            Resource = [
                "arn:aws:s3:::crawler-public*",
                "arn:aws:s3:::aws-glue-*"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource = [
                "arn:aws:logs:*:*:*:/aws-glue/*"
            ]
        }
    ]
  })
}

resource "aws_iam_role" "default" {
  name = "AWSGlueServiceRoleDefault"
  managed_policy_arns = [aws_iam_policy.s3_access.arn]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_glue_catalog_database" "database" {
  name = local.database_name
}

resource "aws_glue_crawler" "root" {
    database_name = aws_glue_catalog_database.database.name
    name          = local.name
    role          = aws_iam_role.default.arn

    configuration = jsonencode(
        {
        Grouping = {
            TableGroupingPolicy = "CombineCompatibleSchemas"
        }
        CrawlerOutput = {
            Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
        }
            Version = 1
        }
    )

    s3_target {
        path = "s3://${local.data_bucket_name}/topics/user_login-v1/"
        sample_size = 5
    }

    s3_target {
        path = "s3://${local.data_bucket_name}/topics/user_login-v2/"
        sample_size = 5
    }

    s3_target {
        path = "s3://${local.data_bucket_name}/topics/user_login-v3/"
        sample_size = 5
    }


    # catalog_target {
    #     database_name = aws_glue_catalog_database.database.name
    #     tables        = [
    #         "user_login-v1",
    #         "user_login-v2",
    #         "user_login-v3",
    #     ]
    # }
}