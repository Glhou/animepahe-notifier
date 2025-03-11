variable "ingress_port" {
  description = "Ingress port for the ecs"
  type        = string
}

variable "subnet_id" {
  description = "Subnet id"
  type        = string
}

variable "sg_id" {
  description = "Security group id"
  type        = string
}

variable "bot_token" {
  description = "Telegram bot token"
  type        = string
}

variable "chat_id" {
  description = "Telegram chat id"
  type        = string
}

variable "lb_tg_arn" {
  description = "Load balancer arn"
  type        = string
}
