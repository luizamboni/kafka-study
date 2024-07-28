
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
}

resource "aws_ecs_task_definition" "task" {
    family                   = "fargate-task-${var.name}"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn
    cpu                      = "256"
    memory                   = "512"

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
        path                = "/"
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

