variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for VPC subnet"
  type        = string
}

variable "ecs_in_port" {
  description = "Ingress port for ecs"
  type        = string
}
