# Create a virtual network within the resource group
resource "azurerm_virtual_network" "pdw-vnet" {
  name                = "${var.AppName}${var.LOB}vnet"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location = "${var.azure_region}"
  address_space       = ["${var.vnet2_address}"]
}


resource "azurerm_virtual_network" "stg-pdw-vnet" {
  name                = "${var.AppName}${var.LOB}stgvnet"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location = "${var.azure_region}"
  address_space       = ["${var.stgvnet2_address}"]
}