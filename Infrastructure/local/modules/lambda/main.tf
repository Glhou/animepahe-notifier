### LAMBDA

resource "aws_lambda_function" "anime-notify-lambda" {
  function_name = "anime-notify-lambda"
  package_type  = "Image"
  image_uri     = "ghcr.io/glhou/animepahe-notifier:main"
  role          = aws_iam_role.iam_for_lambda.arn
  timeout       = 900
  memory_size   = 512
  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [var.sg_id]
  }
  environment {
    variables = {
      ECS_SERVICE_DNS_NAME = var.alb_dns_name
    }
  }
}
