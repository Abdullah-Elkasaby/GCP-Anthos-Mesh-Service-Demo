output "cluster-name" {
  value = module.primary-cluster.name
}


output "project" {
  value = data.google_client_config.current.project
}
