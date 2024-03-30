locals {
  master_ipv4_cidr_blocks = cidrsubnets(var.master_ipv4_cidr_range, 4, 4, 4, 4)
}

data "google_container_engine_versions" "gke_version" {
  location = "us-central1"
  version_prefix = "1.27."
}

resource "google_container_cluster" "gke_clusters" {
  count                    = length(var.cluster_names)
  name                     = var.cluster_names[count.index]
  location                 = var.cluster_zone[count.index]
  initial_node_count       = 1
  remove_default_node_pool = true
  network                  = var.custom_vpc_link
  subnetwork               = var.subnet_link
  deletion_protection      = false

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = local.master_ipv4_cidr_blocks[count.index]
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_range_name
    services_secondary_range_name = var.service_range_name
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    disk_size_gb = var.disk_size
  }
}


resource "google_container_node_pool" "node_pools" {
  count      = length(var.cluster_names)
  name       = "${var.cluster_names[count.index]}-node-pool"
  location   = var.cluster_zone[count.index]
  cluster    = google_container_cluster.gke_clusters[count.index].name
  node_count = var.node_count
  version    = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]


  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}