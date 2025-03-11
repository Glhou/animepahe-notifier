variable "sg_id" {
  description = "Security group id for alb"
  type = string
}

variable "subnet_id" {
  description = "Subnet id for alb"
  type = string
}

variable "ingress_port" {
  description = "Ingress port for the container"
  type = string
}

variable "vpc_id" {
    description = "Vpc id"
    type = string
}

variable "root_domain_name" {
    type=string
    default="localstack.cloud"
}