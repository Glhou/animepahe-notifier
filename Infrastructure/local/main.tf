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

### BUCKET S3

resource "aws_s3_bucket" "anime-notify" {
  bucket = "anime-notify"
}

###  IAM

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

### LAMBDA

resource "aws_lambda_function" "lambda" {
  function_name = "anime-notify"
  package_type  = "Image"
  image_uri     = "gthb.io/glhou/anime-notify:latest"
  role          = aws_iam_role.iam_for_lambda.arn
}



