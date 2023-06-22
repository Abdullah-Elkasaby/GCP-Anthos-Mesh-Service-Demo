resource "google_compute_subnetwork" "subnet" {
  name                     = "subnet-t"
  region                   = "asia-southeast1"
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.0.0.0/24"
  private_ip_google_access = true
}
