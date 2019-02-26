resource "azurerm_subnet" "sqlmi-subnet" {
  name                 = "${var.AppName}${var.LOB}sqlmisubnet"
  resource_group_name  = "${azurerm_resource_group.pdw-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.pdw-vnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet2_address, 2, 1)}"
  #service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_security_group" "sqlmi" {
  name = "${var.AppName}${var.LOB}sqlminsg"
  location = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  security_rule {
    name                       = "rdp"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range    = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }

  tags {
    environment = "${var.DeploymentLifecycle}"
  }
}

resource "azurerm_route_table" "default" {
  name                = "${var.AppName}${var.LOB}rtdefault"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location            = "${var.azure_region}"
  disable_bgp_route_propagation = false

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags {
    environment = "${var.AppName}-${var.LOB}"
  }
}

resource "azurerm_subnet_route_table_association" "sql-mi" {
  subnet_id      = "${azurerm_subnet.sqlmi-subnet.id}"
  route_table_id = "${azurerm_route_table.default.id}"
}

resource "azurerm_subnet_network_security_group_association" "sqlmi" {
  subnet_id                 = "${azurerm_subnet.sqlmi-subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.sqlmi.id}"
}

resource "azurerm_public_ip" "sql-mi-ip" {
  name                = "SQLMI${var.sql_mi_name}GateIP"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location            = "${var.azure_region}"
  allocation_method   = "Dynamic"
  sku                 ="basic"
  tags {
    environment = "${var.AppName}${var.LOB}"
  }
}

data "template_file" "ssmi_server" {
  template = "${file("./templates/sqlmi.json")}"
}

resource "azurerm_template_deployment" "ssmi_server-tpl-deploy" {
  name                = "${var.AppName}${var.LOB}ssmiserverdeploy"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  template_body = "${data.template_file.ssmi_server.rendered}"

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters {
    "location" = "${var.azure_region}"
    "virtualNetworkName" = "${azurerm_virtual_network.pdw-vnet.name}"
    "subnetName" = "${azurerm_subnet.sqlmi-subnet.name}"
    "SSMINAME" = "${var.AppName}ssmi"
    "administratorLogin" = "admin"
    "administratorLoginPassword" = "P@55word!234"
  }

  deployment_mode = "Incremental"
}

output "SSMINAME" {
  value = "${lookup(azurerm_template_deployment.ssmi_server-tpl-deploy.outputs, "SSMINAME")}"
}