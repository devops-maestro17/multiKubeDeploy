output "custom_vpc_link" {
  value = google_compute_network.custom_vpc.self_link
}

output "subnet_link" {
  value = google_compute_subnetwork.private_subnet.self_link
}