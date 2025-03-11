### ECS

resource "aws_ecs_cluster" "telegram-notifier" {
  name = "telegram-notifier"
}

resource "aws_ecs_task_definition" "telegram-notifier" {
  family = "telegram-notifier"
  container_definitions = jsonencode([
    {
      "name" : "docker-telegram-notifier",
      "image" : "ghcr.io/glhou/docker-telegram-notifier:main",
      "memory" : 512,
      "cpu" : 256,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : tonumber(var.ingress_port),
          "hostPort" : tonumber(var.ingress_port)
        }
      ],
      "environment" : [
        {
          "name" : "BOT_TOKEN",
          "value" : var.bot_token
        },
        {
          "name" : "CHAT_ID",
          "value" : var.chat_id
        }
      ]
    }
  ])
  execution_role_arn       = aws_iam_role.iam_for_ecs.arn
  task_role_arn            = aws_iam_role.iam_for_ecs.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "telegram-notifier" {
  name            = "telegram-notifier"
  cluster         = aws_ecs_cluster.telegram-notifier.id
  task_definition = aws_ecs_task_definition.telegram-notifier.arn
  desired_count   = 1
  iam_role        = aws_iam_role.iam_for_ecs.arn
  launch_type     = "FARGATE"


  network_configuration {
    security_groups = [var.sg_id]
    subnets         = [var.subnet_id]
  }

  load_balancer {
    target_group_arn = var.lb_tg_arn
    container_name   = "docker-telegram-notifier"
    container_port   = var.ingress_port
  }
}
