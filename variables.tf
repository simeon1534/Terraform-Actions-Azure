variable "resource_group_name" {
  type = string
  description = "Resource group name in Azure"
}


variable "resource_group_location" {
  type        = string
  description = "Location (region) for the Azure resource group"
}

variable "app_service_plan_name" {
  type        = string
  description = "Name for the Azure App Service Plan"
}

variable "app_service_name" {
  type        = string
  description = "Name for the Azure App Service"
}

variable "sql_server_name" {
  type        = string
  description = "Name for the Azure SQL Server"
}

variable "sql_database_name" {
  type        = string
  description = "Name for the Azure SQL Database"
}

variable "sql_admin_login" {
  type        = string
  description = "SQL Server admin login username"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL Server admin login password"
  #sensitive   = true  # Mark the password as sensitive to hide it in logs
}

variable "firewall_rule_name" {
  type        = string
  description = "Name for the Azure SQL Firewall Rule"
}

variable "repo_url" {
  type        = string
  description = "URL of the Git repository for code deployment"
}
