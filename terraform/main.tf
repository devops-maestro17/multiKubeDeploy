module "vpc" {
  source                    = "./modules/vpc"
  project                   = var.project
  region                    = var.region
  vpc_name                  = var.vpc_name
  private_subnet_name       = var.private_subnet_name
  private_subnet_cidr_range = var.private_subnet_cidr_range
  secondary_ip_ranges       = var.secondary_ip_ranges
  router_name               = var.router_name
  nat_name                  = var.nat_name
  allowed_ports             = var.allowed_ports
}

module "gke" {
  source                 = "./modules/gke"
  master_ipv4_cidr_range = var.master_ipv4_cidr_range
  cluster_names          = var.cluster_names
  cluster_zone           = var.cluster_zone
  node_count             = var.node_count
  machine_type           = var.machine_type
  pod_range_name         = var.pod_range_name
  service_range_name     = var.service_range_name
  custom_vpc_link        = module.vpc.custom_vpc_link
  subnet_link            = module.vpc.subnet_link
  disk_size              = var.disk_size
}