output "subnet_id" {
  value = aws_subnet.telegram_notifier_subnet.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "id" {
  value = aws_vpc.telegram_notifier_vpc.id
}
