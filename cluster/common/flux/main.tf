
provider "null" {
    version = "~>2.0.0"
}

resource "null_resource" "deploy_flux" {
  count  = "${var.enable_flux ? 1 : 0}"
  provisioner "local-exec" {
    command = "KUBECONFIG=${var.output_directory}/kube_config ${path.module}/deploy_flux.sh -f ${var.flux_repo_url} -g ${var.gitops_url} -k ${var.gitops_ssh_key}"
  }

}