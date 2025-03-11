module "vpc" {
  source            = "./modules/vpc"
  cidr_block        = "10.0.0.0/16"
  subnet_cidr_block = "10.0.0.0/24"
  ecs_in_port       = "8081"
}

module "ecs" {
  source       = "./modules/ecs"
  sg_id        = module.vpc.ecs_sg_id
  ingress_port = "8081"
  bot_token    = data.aws_secretsmanager_secret_version.telegram-bot-token.secret_string
  chat_id      = data.aws_secretsmanager_secret_version.telegram-chat-id.secret_string
  subnet_id    = module.vpc.subnet_id
  lb_tg_arn    = module.alb.alb_tg_arn
}

module "lambda" {
  source       = "./modules/lambda"
  sg_id        = module.vpc.lambda_sg_id
  subnet_id    = module.vpc.subnet_id
  alb_dns_name = "${module.alb.alb_dns_name}:443"
}

module "alb" {
  source       = "./modules/alb"
  ingress_port = "8081"
  subnet_id    = module.vpc.subnet_id
  sg_id        = module.vpc.alb_sg_id
  vpc_id       = module.vpc.id
}
