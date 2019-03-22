module "azure-provider" {
    source = "../provider"
}

resource "azurerm_resource_group" "cluster" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.cluster.location}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.kubernetes_version}"

  linux_profile {
    admin_username = "${var.admin_user}"

    ssh_key {
      key_data = "${var.ssh_public_key}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_vm_count}"
    vm_size         = "${var.agent_vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${var.vnet_subnet_id}"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr = "${var.service_CIDR}"
    dns_service_ip = "${var.dns_IP}"
    docker_bridge_cidr = "${var.docker_CIDR}"
  }

  role_based_access_control {
    enabled = true
  /*
    azure_active_directory {
      server_app_id     = "${var.aad_server_app_id}"
      server_app_secret = "${var.aad_server_app_secret}"
      client_app_id     = "${var.aad_client_app_id}"
      tenant_id         = "${var.aad_tenant_id}"
    }
  */
  }

  service_principal {
    client_id     = "${var.service_principal_id}"
    client_secret = "${var.service_principal_secret}"
  }
}
