terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "TerraBro"

    workspaces {
      name = "terraform-gcp-playground"
    }
  }
}

