data "azurerm_resource_group" "spoke" {
    name = "pdw-spoke-rg1"
}
data "azurerm_resource_group" "appbu" {
    name = "${azurerm_resource_group.pdw-rg.name}"
}
data "azurerm_virtual_network" "vnet1" {
  name                = "pdw-vnet1"
  resource_group_name = "${data.azurerm_resource_group.spoke.name}"
}

data "azurerm_virtual_network" "vnet2" {
  name                = "${var.AppName}${var.LOB}vnet"
  resource_group_name = "${data.azurerm_resource_group.appbu.name}"
}


resource "azurerm_virtual_network_peering" "vnet1" {
  name                      = "peer1to2"
  resource_group_name       = "${data.azurerm_resource_group.spoke.name}"
  virtual_network_name      = "${data.azurerm_virtual_network.vnet1.name}"
  remote_virtual_network_id = "${data.azurerm_virtual_network.vnet2.id}"
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "vnet2" {
  name                      = "peer2to1"
  resource_group_name       = "${data.azurerm_resource_group.appbu.name}"
  virtual_network_name      = "${data.azurerm_virtual_network.vnet2.name}"
  remote_virtual_network_id = "${data.azurerm_virtual_network.vnet1.id}"
  allow_virtual_network_access = true
}