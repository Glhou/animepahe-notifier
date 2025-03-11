output "alb_dns_name" {
  value = aws_lb.ecs_alb.dns_name
}

output "alb_tg_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}
