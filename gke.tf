
resource "google_container_cluster" "default" {
  provider                 = google-beta
  project                  = var.project_id
  name                     = var.gke_cluster_name
  location                 = var.zone
  initial_node_count       = var.num_nodes
  networking_mode          = "VPC_NATIVE"
  network                  = google_compute_network.default.name
  subnetwork               = google_compute_subnetwork.default.name
  logging_service          = "none"
  remove_default_node_pool = true

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  default_snat_status {
    disabled = true
  }

  cluster_autoscaling {
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "World"
    }
  }
}



resource "google_container_node_pool" "node-pools" {
  for_each = var.node_pools

  depends_on         = [google_container_cluster.default]
  name               = each.key
  project            = var.project_id
  location           = var.zone
  cluster            = var.gke_cluster_name
  initial_node_count = each.value.initial_node_count

  autoscaling {
    min_node_count = lookup(each.value, "min_node_count", 1)
    max_node_count = lookup(each.value, "max_node_count", 2)
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  node_config {
    machine_type    = lookup(each.value, "machine_type", "f1-micro")
    disk_size_gb    = lookup(each.value, "disk_size_gb", 10)
    disk_type       = lookup(each.value, "disk_type", "pd-standard")
    spot            = lookup(each.value, "spot", false)
    service_account = lookup(each.value, "service_account", "")
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    tags = each.value.tags

    dynamic "taint" {
      for_each = {
        for obj in each.value.taints : "${obj.key}_${obj.value}_${obj.effect}" => obj
      }
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }
  }
}