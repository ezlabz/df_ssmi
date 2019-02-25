# Create a virtual network within the resource group
resource "azurerm_virtual_network" "pdw-vnet" {
  name                = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}-vnet"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location = "${var.azure_region}"
  address_space       = ["${var.vnet2_address}"]
}
