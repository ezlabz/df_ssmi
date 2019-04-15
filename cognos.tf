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

resource "azurerm_public_ip" "jbipcognos" {
  name                = "${var.AppName}jbipcognos"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location            = "${var.azure_region}"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  idle_timeout_in_minutes = 30
  tags {
    environment = "${var.AppName}-${var.LOB}"
  }
}

resource "azurerm_network_interface" "jbniccognos" {
  name                = "${var.AppName}jbniccognos"
  location            = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  
  ip_configuration {
    name                          = "jbconfiguration"
    subnet_id                     = "${azurerm_subnet.cognos-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.jbipcognos.id}"
  }

}

data "azurerm_public_ip" "jbipcognos" {
  name                = "${azurerm_public_ip.jbipcognos.name}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  depends_on          = ["azurerm_virtual_machine.jbcognos"]
}

output "public_ip_address_cognos" {
  value = "${data.azurerm_public_ip.jbipcognos.ip_address}"
}

resource "azurerm_virtual_machine" "jbcognos" {
  name                  = "${var.AppName}jbvmcognos"
  location              = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name   = "${azurerm_resource_group.pdw-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jbniccognos.id}"]
  vm_size               = "Standard_D8s_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdiskjbcognos"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "${random_string.password.result}"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  tags {
    environment = "${var.AppName}${var.LOB}"
  }
  depends_on = [ "random_string.password"]
}


#Gateway jbvm

resource "azurerm_public_ip" "jbipgateway" {
  name                = "${var.AppName}jbipgateway"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location            = "${var.azure_region}"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  idle_timeout_in_minutes = 30
  tags {
    environment = "${var.AppName}-${var.LOB}"
  }
}

resource "azurerm_network_interface" "jbnicgateway" {
  name                = "${var.AppName}jbnicgateway"
  location            = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  
  ip_configuration {
    name                          = "jbconfigurationgateway"
    subnet_id                     = "${azurerm_subnet.cognos-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.jbipgateway.id}"
  }

}

data "azurerm_public_ip" "jbipgateway" {
  name                = "${azurerm_public_ip.jbipgateway.name}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  depends_on          = ["azurerm_virtual_machine.jbgateway"]
}

output "public_ip_address_gateway" {
  value = "${data.azurerm_public_ip.jbipgateway.ip_address}"
}

resource "azurerm_virtual_machine" "jbgateway" {
  name                  = "${var.AppName}jbvmgateway"
  location              = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name   = "${azurerm_resource_group.pdw-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jbnicgateway.id}"]
  vm_size               = "Standard_D8s_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdiskjbgateway"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = "hostnamegateway"
    admin_username = "testadmin"
    admin_password = "${random_string.password.result}"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  tags {
    environment = "${var.AppName}${var.LOB}"
  }
  depends_on = [ "random_string.password"]
}