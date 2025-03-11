resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = [var.subnet_id]
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-tg"
  port        = var.ingress_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "ecs_listener_http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_listener" "ecs_listener_https" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}
