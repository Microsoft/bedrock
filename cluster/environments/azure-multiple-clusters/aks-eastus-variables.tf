variable "east_resource_group_name" {
  type = "string"
}

variable "east_resource_group_location" {
  type    = "string"
}

variable "gitops_east_path" {
  type = "string"
}

variable "east_address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.10.0.0/16"
}

variable "east_subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "east_service_CIDR" {
  default = "10.0.0.0/16"
  description ="Used to assign internal services in the AKS cluster an IP address. This IP address range should be an address space that isn't in use elsewhere in your network environment. This includes any on-premises network ranges if you connect, or plan to connect, your Azure virtual networks using Express Route or a Site-to-Site VPN connections."
  type = "string"
}

variable "east_dns_IP" {
  default = "10.0.0.10"
  description = "should be the .10 address of your service IP address range"
  type = "string"
}

variable "east_docker_CIDR" {
  default = "172.17.0.1/16"
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Default of 172.17.0.1/16."
}