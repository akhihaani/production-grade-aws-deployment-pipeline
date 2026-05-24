## ECS Cluster
resource "aws_cloudwatch_log_group" "memos_cloudwatch_log_group" {
  name = "memos_cloudwatch_log_group"
}

resource "aws_ecs_cluster" "memos_cluster" {
  name = "memos_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.memos_cloudwatch_log_group.name
      }
    }
  }
}

## Fargate Service


## Task Definition
resource "aws_ecs_task_definition" "memos_task_def" {
  family                   = "memos_task_family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.memos_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }


  container_definitions = jsonencode([
    {
      name      = "memos"
      image     = "${var.memos_repo_url}:09495e4"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8081
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.memos_cloudwatch_log_group.name
          "awslogs-region"        = "eu-west-2"
          "awslogs-stream-prefix" = "memos"
        }
      },
    }
  ])

  lifecycle { ignore_changes = [container_definitions] }
}

## ECS Service
### Inside the cluster, manages tasks
resource "aws_ecs_service" "memos_service" {
  name            = "memos_service"
  cluster         = aws_ecs_cluster.memos_cluster.id
  task_definition = aws_ecs_task_definition.memos_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = [var.memos_ecs_task_sg]
    subnets          = var.memos_public_subnets
  }

  load_balancer {
    target_group_arn = var.memos_lb_target_group_arn
    container_name   = "memos"
    container_port   = 8081
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

## IAM Roles

resource "aws_iam_role" "memos_role" {
  name = "memos_role_1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "memos-role-policy" {
  role       = aws_iam_role.memos_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
