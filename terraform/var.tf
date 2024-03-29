variable "gcp_project_id" {
}

variable "gcp_region" {
  default = "us-west2"
}

provider "google" {
  credentials = file("./account.json")
  project     = var.gcp_project_id
  region      = var.gcp_region
}