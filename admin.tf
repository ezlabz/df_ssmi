resource "azurerm_subnet" "admin-subnet" {
  name                 = "${var.AppName}${var.LOB}adminsubnet"
  resource_group_name  = "${azurerm_resource_group.pdw-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.pdw-vnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet2_address, 2, 0)}"

  #service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_security_group" "admin_access" {
  name                = "${var.AppName}${var.LOB}adminnsg"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  security_rule {
    name                       = "admin_access"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["9000", "9003", "1433", "1440", "1452","3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "${var.DeploymentLifecycle}"
  }
}

resource "azurerm_subnet_network_security_group_association" "admin" {
  subnet_id                 = "${azurerm_subnet.admin-subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.admin_access.id}"
}

resource "azurerm_public_ip" "jbip" {
  name                = "${var.AppName}jbip"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location            = "${var.azure_region}"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  idle_timeout_in_minutes = 30
  tags {
    environment = "${var.AppName}-${var.LOB}"
  }
}

resource "azurerm_network_interface" "jbnic" {
  name                = "${var.AppName}jbnic"
  location            = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  
  ip_configuration {
    name                          = "jbconfiguration"
    subnet_id                     = "${azurerm_subnet.admin-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.jbip.id}"
  }

}

data "azurerm_public_ip" "jbip" {
  name                = "${azurerm_public_ip.jbip.name}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  depends_on          = ["azurerm_virtual_machine.jb"]
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.jbip.ip_address}"
}

resource "azurerm_virtual_machine" "jb" {
  name                  = "${var.AppName}jbvm"
  location              = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name   = "${azurerm_resource_group.pdw-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jbnic.id}"]
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
    name              = "myosdiskjb"
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


