resource "random_string" "unique_id" {
  length  = 4
  special = false
}

locals {
  unique_id = lower(random_string.unique_id.result)
}