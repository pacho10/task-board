terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.1"
    }
  }
}

# 2. Configure the AzureRM Provider
provider "azurerm" {
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "TaskBoardRG${random_integer.ri.result}"
  location = "West Europe"
}

resource "azurerm_service_plan" "sp" {
  name                = "task-board-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "lwa" {
  name                = "TaskBoardAppPlamen"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.sp.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection {
    name = "DefaultConnection"
    type = "SQLAzure"
    value = "Data Source=tcp:${fully qualified domain name of the MSSQLserver},1433;Initial Catalog=${name of the SQL database};UserID=${username of the MSSQL server administrator};Password=${password ofthe MSSQL server administrator};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}

resource "azurerm_sql_server" "mssql" {
  name                         = "mssqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

data "azurerm_mssql_database" "database" {
  name      = "TaskBoard"
  server_id = azurerm_mssql_server.mssql.id
  collation = 
}