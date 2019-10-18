
variable "cosmos_db_account" {
  type        = "string"
  description = "name of cosmosdb account"
}

variable "cosmos_db_name" {
  type        = "string"
  description = "CosmosDB name"
}

variable "cosmos_db_collection" {
  type        = "string"
  description = "name of collection"
}

variable "cosmos_db_sp_names" {
  type        = "string"
  description = "list of sp names are separated by ','"
}

variable "vault_name" {
  type        = "string"
  description = "key vault to store auth key of cosmosdb connection"
}
