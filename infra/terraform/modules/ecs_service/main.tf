
locals {
  optional_policy = jsondecode(var.optional_policy_json)
}

resource "aws_iam_policy" "optional_policy" {
  name        = "OptionalPolicy-${var.name}"
  description = "Optional policy for the ECS task execution role"
  policy      = jsonencode(local.optional_policy)
  count       = local.optional_policy == {} ? 0 : 1
}

resource "aws_iam_role_policy_attachment" "optional_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.optional_policy[count.index].arn
  count      = local.optional_policy == {} ? 0 : 1
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.name}"
  retention_in_days = 7
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole-${var.name}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action    = "sts:AssumeRole"
                Effect    = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    ]

    tags = var.tags
}

resource "aws_iam_role" "ecs_task_role" {
    name = "ecsTaskRole-${var.name}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action    = "sts:AssumeRole"
                Effect    = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            },
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    ]

    tags = var.tags
}

resource "aws_ecs_task_definition" "task" {
    family                   = "fargate-task-${var.name}"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn
    cpu                      = var.cpu
    memory                   = var.memory

    container_definitions = jsonencode([{
        name      = "app"
        image     = var.image
        essential = true
        environment = [
            for key, value in var.environment_variables : {
                name  = key
                value = value
            }
        ]
        command = var.command
        portMappings = [
            {
                containerPort = var.container_port
                hostPort      = var.container_port
            }
        ]

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-create-group"  = "true"
                "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
                "awslogs-region"        = var.region
                "awslogs-stream-prefix" = "ecs"
            }
        }
    }])
}

resource "aws_ecs_service" "service" {
    name            = "fargate-service-${var.name}"
    cluster         = var.cluster_id
    task_definition = aws_ecs_task_definition.task.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = var.subnet_ids
        security_groups  = [var.security_group_id]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.main.arn
        container_name   = "app"
        container_port   = var.container_port
    }
}


resource "aws_lb" "main" {
    name               = "main-alb-${var.name}"
    internal           = var.internal
    load_balancer_type = "application"
    security_groups    = [var.security_group_id]
    subnets            = var.subnet_ids

    enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
    name     = "main-targets-${var.name}"
    port     = var.container_port
    protocol = "HTTP"
    vpc_id   = var.vpc_id
    target_type = "ip"
    health_check {
        path                = var.health_check
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200"
    }
}

resource "aws_lb_listener" "main" {
    load_balancer_arn = aws_lb.main.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
}

