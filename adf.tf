resource "azurerm_subnet" "adf-subnet" {
  name                 = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}-adfsubnet"
  resource_group_name  = "${azurerm_resource_group.pdw-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.pdw-vnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet2_address, 2, 2)}"
  #service_endpoints    = ["Microsoft.Sql"]
}


resource "azurerm_network_security_group" "adf" {
  name                = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}-adfnsg"
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

resource "azurerm_subnet_network_security_group_association" "adf" {
  subnet_id                 = "${azurerm_subnet.adf-subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.adf.id}"
}