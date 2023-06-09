resource "google_compute_router" "router" {
  name    = "nat-router-${local.unique_id}"
  project = google_compute_subnetwork.default.project
  region  = google_compute_subnetwork.default.region
  network = google_compute_network.default.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "router-nat-${local.unique_id}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  project                            = google_compute_router.router.project
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

