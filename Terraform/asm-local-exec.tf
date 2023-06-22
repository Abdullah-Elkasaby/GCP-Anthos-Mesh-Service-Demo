resource "null_resource" "add-vars-to-asm-script" {

  provisioner "local-exec" {
    command = "sed -i '4,7d' ../get-anthos-ready.sh"

  }
  provisioner "local-exec" {
    command = "sed -i '3s/.*/&\\nPROJECT_ID=\"${data.google_client_config.current.project}\"\\nCLUSTER_NAME=\"${module.primary-cluster.name}\"\\nCLUSTER_ZONE=\"${var.primary_zones[0]}\"/' ../get-anthos-ready.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

