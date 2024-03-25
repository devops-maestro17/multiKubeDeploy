provider "google" {
  project = "genuine-amulet-416011"
  region = "us-central1"
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_compute_network" "vpc" {
  name = "vpc-network"
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false
  delete_default_routes_on_create = false

  depends_on = [ 
    google_project_service.compute,
    google_project_service.container
   ]
}

resource "google_compute_subnetwork" "private_subnet" {
  name = "private-subnet"
  ip_cidr_range = "10.0.0.0/18"
  region = "us-central1"
  network = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }

  secondary_ip_range {
    range_name = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }
}

resource "google_compute_router" "router" {
    name = "router"
    region = "us-central1"
    network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name = "nat"
  router = google_compute_router.router.name
  region = "us-central1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option = "MANUAL_ONLY"

  subnetwork {
    name = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  name = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [ google_project_service.compute ]
}

resource "google_compute_firewall" "allow-ssh" {
  name = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc.self_link
  subnetwork               = google_compute_subnetwork.private_subnet.self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"


  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "devops-v4.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.primary.id
  node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = "e2-small"

    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}