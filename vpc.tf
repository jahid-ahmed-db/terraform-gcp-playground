

resource "google_compute_network" "default" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
  project                 = var.project_id
  routing_mode            = "REGIONAL"
}



resource "google_compute_subnetwork" "default" {
  depends_on    = [google_compute_network.default]
  name          = "${var.gke_cluster_name}-subnet"
  project       = google_compute_network.default.project
  region        = var.region
  network       = google_compute_network.default.name
  ip_cidr_range = var.cluster_subnetwork_cidr_range
}

resource "google_compute_address" "static-ingress" {
  name     = "static-ingress-${local.unique_id}"
  project  = var.project_id
  region   = var.region
  provider = google-beta

  labels = {
    kubeip = "static-ingress"
  }
}



resource "google_compute_firewall" "default" {
  name    = "public-ingress-${local.unique_id}"
  network = google_compute_network.default.self_link
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.node_pools.ingress.tags
}