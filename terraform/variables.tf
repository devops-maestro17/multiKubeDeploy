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
  type    = string
  default = "private-subnet"
}

variable "private_subnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "secondary_ip_ranges" {
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))

  default = [
    {
      range_name    = "pods-range"
      ip_cidr_range = "10.1.0.0/16"
    },
    {
      range_name    = "services-range"
      ip_cidr_range = "10.2.0.0/20"
    }
  ]
}

variable "router_name" {
  type    = string
  default = "router"
}

variable "nat_name" {
  type    = string
  default = "nat"
}

variable "allowed_ports" {
  type = list(object({
    port        = number
    protocol    = string
    description = string
  }))

  default = [
    {
      port        = 22
      protocol    = "tcp"
      description = "Allow SSH"
    }
  ]
}

variable "master_ipv4_cidr_range" {
  description = "CIDR range for the master IP addresses"
  type        = string
  default     = "172.16.0.0/24"
}

variable "cluster_names" {
  description = "List of cluster names"
  type        = list(string)
}

variable "cluster_zone" {
  description = "Zones where cluster will be deployed"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c", "us-central1-f"]
}

variable "node_count" {
  description = "Number of nodes in each cluster"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
  default     = "e2-medium"
}

variable "pod_range_name" {
  description = "Name of the secondary IP range for pods"
  type        = string
  default     = "pods-range"
}

variable "service_range_name" {
  description = "Name of the secondary IP range for services"
  type        = string
  default     = "services-range"
}

variable "disk_size" {
  description = "Disk size of each cluster"
  type        = number
  default     = 25
}