resource "azurerm_subnet" "cognos-subnet" {
  name                 = "${var.AppName}${var.LOB}cognossubnet"
  resource_group_name  = "${azurerm_resource_group.pdw-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.pdw-vnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet2_address, 2, 3)}"
  #service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_security_group" "cognos" {
  name                = "${var.AppName}${var.LOB}cognosnsg"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  security_rule {
    name                       = "rdp"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }

  tags {
    environment = "${var.DeploymentLifecycle}"
  }
}

resource "azurerm_subnet_network_security_group_association" "cognos" {
  subnet_id                 = "${azurerm_subnet.cognos-subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.cognos.id}"
}
