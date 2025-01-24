provider "aws" {

  access_key = "mock_access_key"
  secret_key = "mock_secret_key"
  region     = "us-east-1"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://s3.localhost.localstack.cloud:4566"
  }
}

### SECRET MANAGER
data "aws_secretsmanager_secret" "telegram-bot-token-secret" {
  name = "BOT_TOKEN"
}

data "aws_secretsmanager_secret_version" "telegram-bot-token" {
  secret_id = data.aws_secretsmanager_secret.telegram-bot-token-secret.id
}

data "aws_secretsmanager_secret" "telegram-chat-id-secret" {
  name = "CHAT_ID"
}

data "aws_secretsmanager_secret_version" "telegram-chat-id" {
  secret_id = data.aws_secretsmanager_secret.telegram-chat-id-secret.id
}

### BUCKET S3

resource "aws_s3_bucket" "anime-notify-bucket" {
  bucket = "anime-notify-bucket"
}

### IAM POLICY DOCUMENT

data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"] # Logs resources across all regions and accounts
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::anime-notify-bucket/*"]
  }
}

### IAM ROLE

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

### IAM ROLE POLICY ATTACHMENT

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name   = "lambda_execution_policy"
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.lambda_execution_policy.json
}

### LAMBDA

resource "aws_lambda_function" "anime-notify-lambda" {
  function_name = "anime-notify-lambda"
  package_type  = "Image"
  image_uri     = "ghcr.io/glhou/animepahe-notifier:main"
  role          = aws_iam_role.iam_for_lambda.arn
  timeout       = 900
  memory_size   = 512
}

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
      "environment" : [
        {
          "name" : "BOT_TOKEN",
          "value" : data.aws_secretsmanager_secret_version.telegram-bot-token.secret_string
        },
        {
          "name" : "CHAT_ID",
          "value" : data.aws_secretsmanager_secret_version.telegram-chat-id.secret_string
        }
      ]
    }
  ])
  execution_role_arn       = aws_iam_role.iam_for_lambda.arn
  task_role_arn            = aws_iam_role.iam_for_lambda.arn
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
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.telegram-notifier.id]
    security_groups  = [aws_security_group.telegram-notifier.id]
    assign_public_ip = true
  }
}

### NETWORK

resource "aws_vpc" "telegram-notifier" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "telegram-notifier" {
  vpc_id            = aws_vpc.telegram-notifier.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "telegram-notifier" {
  vpc_id = aws_vpc.telegram-notifier.id
}

