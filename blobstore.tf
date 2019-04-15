resource "azurerm_storage_account" "stgact" {
  name                = "${var.AppName}${var.LOB}storage"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location = "${var.azure_region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "pdw-container" {
  name                  = "${var.AppName}${var.LOB}data"
  resource_group_name   = "${azurerm_resource_group.pdw-rg.name}"
  storage_account_name  = "${azurerm_storage_account.stgact.name}"
  container_access_type = "private"
}