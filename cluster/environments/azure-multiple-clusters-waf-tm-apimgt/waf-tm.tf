

# # create public IP east
# resource "azurerm_public_ip" "wafipeast" {
#   name                         = "${var.prefix}-wafipeast"
#   location                     = "eastus"
#   resource_group_name          = "${var.resource_group_name_east}"
#   public_ip_address_allocation = "dynamic"

#   tags {
#     environment = "${var.tag}"
#   }
# }

locals {
  east_rg_name                 = "${azurerm_resource_group.eastrg.name}"
  east_rg_location             = "${azurerm_resource_group.eastrg.location}"

  west_rg_name                 = "${azurerm_resource_group.westrg.name}"
  west_rg_location             = "${azurerm_resource_group.westrg.location}"
  
  central_rg_name                 = "${azurerm_resource_group.centralrg.name}"
  central_rg_location             = "${azurerm_resource_group.centralrg.location}"


}


module "east_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.east_rg_name : module.east_aks.cluster_derived_resource_group}"
  resource_location                   = "${local.east_rg_location}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.east_rg_location}-wafipeast"
  public_ip_name                      = "${var.cluster_name}-wafipeast"
  ip_address_out_filename             = "${local.east_ip_address_out_filename}"

  tags = {
    environment = "azure-multiple-clusters-waf-tm-apimgt east - ${var.cluster_name} - public ip"
    # kubedone    = "${module.east_aks.kubeconfig_done}"
  }
}

# Create an application gateway east
resource "azurerm_application_gateway" "appgweast" {
  name                = "${var.prefix}appgweast"
  resource_group_name = "${var.resource_group_name_east}"
  location            = "eastus"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.east_vnet.vnet_subnet_ids[1]}" #  {module.central_vnet.vnet_subnet_ids[0]
    # subnet_id = "${module.central_vnet.vnet_subnet_ids[0]}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    public_ip_address_id = "${module.east_tm_endpoint.pip.id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    # ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    # cookie_based_affinity = "Enabled"                    // "Disabled"
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
  
  }


  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httplstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

depends_on = [
     "azurerm_public_ip.wafipeast"

  ]
}

################### westUS

# # create public IP west
# resource "azurerm_public_ip" "wafipwest" {
#   name                         = "${var.prefix}-wafipwest"
#   location                     = "westus"
#   resource_group_name          = "${var.resource_group_name_west}"
#   public_ip_address_allocation = "dynamic"

#   tags {
#     environment = "${var.tag}"
#   }
# }


module "west_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.west_rg_name : module.west_aks.cluster_derived_resource_group}"
  resource_location                   = "${local.west_rg_location}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.west_rg_location}-wafipwest"
  public_ip_name                      = "${var.cluster_name}-wafipwest"
  ip_address_out_filename             = "${local.west_ip_address_out_filename}"

  tags = {
    environment = "azure-multiple-clusters-waf-tm-apimgt west- ${var.cluster_name} - public ip"
    # kubedone    = "${module.east_aks.kubeconfig_done}"
  }
}

# Create an application gateway east
resource "azurerm_application_gateway" "appgwwest" {
  name                = "${var.prefix}appgwwest"
  resource_group_name = "${var.resource_group_name_west}"
  location            = "westus"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.west_vnet.vnet_subnet_ids[1]}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    # public_ip_address_id = "${azurerm_public_ip.wafipwest.id}" module.east_tm_endpoint.pip.id
    public_ip_address_id = "${module.west_tm_endpoint.pip.id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    # ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
  
  }


  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httplstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

  
}

####################### Central US

# create public IP Central
# resource "azurerm_public_ip" "wafipcentral" {
#   name                         = "${var.prefix}-wafipcentral"
#   location                     = "centralus"
#   resource_group_name          = "${var.resource_group_name_central}"
#   public_ip_address_allocation = "dynamic"

#   tags {
#     environment = "${var.tag}"
#   }
# }


module "central_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.central_rg_name : module.central_aks.cluster_derived_resource_group}"
  resource_location                   = "${local.central_rg_location}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.central_rg_location}-wafipeast"
  public_ip_name                      = "${var.cluster_name}-wafipeast"
  ip_address_out_filename             = "${local.central_ip_address_out_filename}"

  tags = {
    environment = "azure-multiple-clusters-waf-tm-apimgt - ${var.cluster_name} - public ip"
    # kubedone    = "${module.east_aks.kubeconfig_done}"
  }
}

# Create an application gateway east
resource "azurerm_application_gateway" "appgwcentral" {
  name                = "${var.prefix}appgwcentral"
  resource_group_name = "${var.resource_group_name_central}"
  location            = "centralus"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.central_vnet.vnet_subnet_ids[1]}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    public_ip_address_id = "${module.central_tm_endpoint.pip.id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    # ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    # cookie_based_affinity = "Enabled"                    // "Disabled"
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
  
  }


  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httplstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

depends_on = 
     ["azurerm_public_ip.wafipcentral","azurerm_subnet.tfwafnetcentral"]

  
  
}

################ Traffic manager


# resource "azurerm_resource_group" "tmrg" {
#   name     = "${var.traffic_manager_resource_group_name}"
#   location = "${var.traffic_manager_resource_group_location}"
# }

# # Creates Azure Traffic Manager Profile
# resource "azurerm_traffic_manager_profile" "profile" {
#   name                   = "${var.traffic_manager_profile_name}"
#   resource_group_name    = "${var.traffic_manager_resource_group_name}"
#   traffic_routing_method = "Weighted"

#   dns_config {
#     relative_name = "${var.traffic_manager_dns_name}"
#     ttl           = 30
#   }

#   monitor_config {
#     protocol = "${var.traffic_manager_monitor_protocol}"
#     port     = "${var.traffic_manager_monitor_port}"
#     path     = "/"
#   }

#   tags = "${var.tags}"
# }

# resource "azurerm_traffic_manager_endpoint" "eastusep" {
#   name                = "eastusep"
#   resource_group_name = "${var.traffic_manager_resource_group_name}"
#   profile_name        = "${var.traffic_manager_profile_name}"
#   target              = "${azurerm_public_ip.wafipeast.ip_address}"
#   type                = "externalEndpoints"
#   weight              = 100

#   depends_on = 
#      ["azurerm_public_ip.wafipeast"]

  
# }

# resource "azurerm_traffic_manager_endpoint" "westusep" {
#   name                = "westusep"
#   resource_group_name = "${var.traffic_manager_resource_group_name}"
#   profile_name        = "${var.traffic_manager_profile_name}"
#   target              = "${azurerm_public_ip.wafipwest.ip_address}"
#   type                = "externalEndpoints"
#   weight              = 200
#    depends_on = 
#      ["azurerm_public_ip.wafipwest"]

  
# }

# resource "azurerm_traffic_manager_endpoint" "centralusep" {
#   name                = "centralusep"
#   resource_group_name = "${var.traffic_manager_resource_group_name}"
#   profile_name        = "${var.traffic_manager_profile_name}"
#   target              = "${azurerm_public_ip.wafipcentral.ip_address}"
#   type                = "externalEndpoints"
#   weight              = 300
#  depends_on = 
#      ["azurerm_public_ip.wafipcentral"]

  
# }