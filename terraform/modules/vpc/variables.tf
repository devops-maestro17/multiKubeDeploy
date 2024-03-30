variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "private_subnet_cidr_range" {
  type = string
}

variable "secondary_ip_ranges" {
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
}

variable "router_name" {
  type = string
}

variable "nat_name" {
  type = string
}

variable "allowed_ports" {
  type = list(object({
    port        = number
    protocol    = string
    description = string
  }))
}