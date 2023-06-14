

variable "region" {
  description = "The region to host the cluster in"
}

variable "zone" {
  description = "The zone to host the cluster in (required if is a zonal cluster)"

}

variable "network_name" {
  description = "The name of the network"
}

variable "gke_cluster_name" {
  description = "The name of the cluster"
  default     = "lean-gke-cluster"
}

variable "num_nodes" {
  description = "The number of cluster nodes"
}

variable "disk_size" {
  description = "The disk size of the cluster nodes"
}

variable "node_pools" {
  default = {
    ingress = {
      machine_type       = "e2-small"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 1
      spot               = true
      auto_repair        = true
      auto_upgrade       = true
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      tags = [
        "ingress"
      ]
      taints = [
        {
          key    = "ingress"
          value  = true
          effect = "NO_EXECUTE"
        }
      ]
    }
    shared = {
      machine_type       = "e2-small"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 5
      spot               = true
      auto_repair        = true
      auto_upgrade       = true
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      taints             = []
      tags = [
        "shared"
      ]
    }
  }
}
