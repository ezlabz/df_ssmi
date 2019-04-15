resource "azurerm_subnet" "sqlmi-subnet" {
  name                 = "${var.AppName}${var.LOB}sqlmisubnet"
  resource_group_name  = "${azurerm_resource_group.pdw-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.pdw-vnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet2_address, 2, 1)}"
  #service_endpoints    = ["Microsoft.Sql"]
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
    "virtualNetworkResourceGroupName" = "${azurerm_resource_group.pdw-rg.name}"
    "virtualNetworkName" = "${azurerm_virtual_network.pdw-vnet.name}"
    "subnetName" = "${azurerm_subnet.sqlmi-subnet.name}"
    "skuName" = "BC_Gen5"
    "skuEdition" = "BusinessCritical"
    "managedInstanceName" = "${var.AppName}ssmipdwpoc"
    "administratorLogin" = "sqlmiadmin"
    "administratorLoginPassword" = "${random_string.password.result}"
    #"storageSizeInGB" = 3008
    #"vCores" = 32
    "licenseType" = "BasePrice"
    "hardwareFamily" = "Gen5"
    "collation" = "SQL_Latin1_General_CP1_CI_AS"
  }
  depends_on = [ "random_string.password", "azurerm_subnet.sqlmi-subnet", "azurerm_virtual_network.pdw-vnet" ]
  deployment_mode = "Incremental"
}

#output "SSMINAME" {
#  value = "${lookup(azurerm_template_deployment.ssmi_server-tpl-deploy.outputs, "SSMINAME")}"
#}