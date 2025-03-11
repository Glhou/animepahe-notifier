### NETWORK

resource "aws_vpc" "telegram_notifier_vpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "telegram_notifier_subnet" {
  vpc_id     = aws_vpc.telegram_notifier_vpc.id
  cidr_block = var.subnet_cidr_block
}



resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.telegram_notifier_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ecs" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = aws_vpc.telegram_notifier_vpc.cidr_block
  from_port         = var.ecs_in_port
  to_port           = var.ecs_in_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_http_ecs" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = aws_vpc.telegram_notifier_vpc.cidr_block
  from_port         = var.ecs_in_port
  to_port           = var.ecs_in_port
  ip_protocol       = "tcp"
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.telegram_notifier_vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_lambda" {
  security_group_id = aws_security_group.lambda_sg.id
  cidr_ipv4         = aws_vpc.telegram_notifier_vpc.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_http_lambda" {
  security_group_id = aws_security_group.lambda_sg.id
  cidr_ipv4         = aws_vpc.telegram_notifier_vpc.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.telegram_notifier_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = aws_vpc.telegram_notifier_vpc.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_http_alb" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = aws_vpc.telegram_notifier_vpc.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

