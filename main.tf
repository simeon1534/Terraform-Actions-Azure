terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}


# Creates the Linux App Service Plan
resource "azurerm_service_plan" "sp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

# Creates mssql server
resource "azurerm_mssql_server" "ms" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password


}

#Creates sql database
resource "azurerm_mssql_database" "md" {
  name      = "${var.sql_database_name}${random_integer.ri.result}"
  server_id = azurerm_mssql_server.ms.id

  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"
  zone_redundant = false
}

# Create firewall rule
resource "azurerm_mssql_firewall_rule" "mfr" {
  name             = "${var.firewall_rule_name}${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.ms.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Creates the web and pass in the app service plan id
resource "azurerm_linux_web_app" "lwa" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.sp.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.ms.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.md.name};User ID=${azurerm_mssql_server.ms.administrator_login};Password=${azurerm_mssql_server.ms.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_app_service_source_control" "assc" {
  app_id                 = azurerm_linux_web_app.lwa.id
  repo_url               = var.repo_url
  branch                 = "master"
  use_manual_integration = true

}
