variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "vault_name" {
  type        = "string"
  description = "Name of the keyvault to create"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  default     = "standard"
}

variable "vault_reader_identity" {
  description = "name of user assigned identity (MSI) that will be granted reader role to key vault. The identity name must be by unique within subscription"
  type        = "string"
}

variable "aks_cluster_name" {
  type        = "string"
  description = "name of AKS cluster"
}

variable "aks_cluster_spn_name" {
  type        = "string"
  description = "name of AKS cluster service principal"
}

variable "aks_cluster_resource_group_name" {
  type        = "string"
  description = "AKS cluster resource group (NOT Node resource group name that starts with MC)"
}

variable "aks_cluster_location" {
  type = "string"
  description = "AKS resource group location"
}