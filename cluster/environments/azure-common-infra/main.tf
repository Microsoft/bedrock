#terraform {
#  backend "azurerm" {}
#}

module "provider" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/provider"
  source = "../../azure/provider"
}

resource "azurerm_resource_group" "global_rg" {
  count    = "${var.global_resource_group_preallocated ? 0 : 1}"
  name     = "${var.global_resource_group_name}"
  location = "${var.global_resource_group_location}"
}

data "azurerm_resource_group" "global_rg" {
  name = "${var.global_resource_group_preallocated ? var.global_resource_group_name : join("", azurerm_resource_group.global_rg.*.name)}"
}
