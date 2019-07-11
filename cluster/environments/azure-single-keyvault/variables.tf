variable "acr_enabled" {
  type    = "string"
  default = "true"
}

variable "address_space" {
  type = "string"
}

variable "agent_vm_count" {
  type = "string"
}

variable "agent_vm_size" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "dns_prefix" {
  type = "string"
}

variable "flux_recreate" {
  description = "Make any change to this value to trigger the recreation of the flux execution script."
  type        = "string"
  default     = ""
}

variable "kubeconfig_recreate" {
  description = "Any change to this variable will recreate the kube config file to local disk."
  type        = "string"
  default     = ""
}

variable "gitops_poll_interval" {
  type    = "string"
  default = "5m"
}

variable "gitops_ssh_url" {
  type = "string"
}

variable "gitops_url_branch" {
  type    = "string"
  default = "master"
}

variable "gitops_ssh_key" {
  type = "string"
}

variable "gitops_path" {
  type    = "string"
  default = ""
}

variable "keyvault_name" {
  type = "string"
}

variable "keyvault_resource_group" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location" {
  type = "string"
}

variable "resource_group_preallocated" {
  description = "boolean value that when set to true, the specified resource group is assumed to exist.  it will not be feleted.  when set to false, the resource group will be 'managed' by Terraform and deleted on a 'terraform destroy'"
  default = false
}

variable "ssh_public_key" {
  type = "string"
}

variable "service_principal_id" {
  type = "string"
}

variable "service_principal_secret" {
  type = "string"
}

variable "subnet_prefixes" {
  type = "string"
}

variable "vnet_subnet_id" {
  type = "string"
}

variable "network_policy" {
  default     = "azure"
  description = "Network policy to be used with Azure CNI. Either azure or calico."
}
