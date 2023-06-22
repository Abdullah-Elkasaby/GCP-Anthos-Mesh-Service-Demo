



module "primary-cluster" {
  name                    = "primary"
  project_id              = module.project-services.project_id
  source                  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  regional                = false
  region                  = "asia-southeast1"
  network                 = google_compute_network.vpc.name
  subnetwork              = google_compute_subnetwork.subnet.name
  ip_range_pods           = ""
  ip_range_services       = ""
  zones                   = ["asia-southeast1-a"]
  release_channel         = "REGULAR"
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }



  node_pools = [
    {
      name         = "default-node-pool"
      autoscaling  = true
      auto_upgrade = true

      # for autoscaling
      min_node_count = 4
      max_node_count = 10
      node_count   = 1
      machine_type = "e2-standard-4"
    },
  ]
}
