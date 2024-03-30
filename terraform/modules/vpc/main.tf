# Define the GCP provider
provider "google" {
  project = var.project
  region  = var.region
}

# Create a VPC network
resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create a private subnet for GKE clusters
resource "google_compute_subnetwork" "private_subnet" {
  name                     = var.private_subnet_name
  ip_cidr_range            = var.private_subnet_cidr_range
  network                  = google_compute_network.custom_vpc.self_link
  region                   = var.region
  private_ip_google_access = true

  # Secondary IP ranges for pods and services
  dynamic "secondary_ip_range" {
    for_each = var.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# Create a Cloud Router
resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.custom_vpc.self_link
}

# Create a NAT gateway and associate it with the private subnet
resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Create a Firewall rule
resource "google_compute_firewall" "allow_traffic" {
  name    = "allow-traffic"
  network = google_compute_network.custom_vpc.name

  dynamic "allow" {
    for_each = var.allowed_ports
    content {
      protocol = allow.value.protocol
      ports    = [allow.value.port]
    }
  }

  source_ranges = ["0.0.0.0/0"]
}