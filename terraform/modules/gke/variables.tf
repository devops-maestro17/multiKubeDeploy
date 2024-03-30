variable "master_ipv4_cidr_range" {
  description = "CIDR range for the master IP addresses"
  type        = string
}

variable "cluster_names" {
  description = "List of cluster names"
  type        = list(string)
}

variable "cluster_zone" {
  description = "Zone where cluster will be deployed"
  type        = list(string)
}

variable "node_count" {
  description = "Number of nodes in each cluster"
  type        = number
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
}

variable "pod_range_name" {
  description = "Name of the secondary IP range for pods"
  type        = string
}

variable "service_range_name" {
  description = "Name of the secondary IP range for services"
  type        = string
}

variable "custom_vpc_link" {
  description = "Link to the custom VPC in the VPC module"
  type        = string
}

variable "subnet_link" {
  description = "Link to the private subnet in the VPC module"
  type        = string
}

variable "disk_size" {
  description = "Disk size of each cluster"
  type        = number
}