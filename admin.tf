resource "azurerm_subnet" "admin-subnet" {
  name                 = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}-adminsubnet"
  resource_group_name  = "${azurerm_resource_group.pdw-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.pdw-vnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet2_address, 2, 0)}"

  #service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_security_group" "admin_access" {
  name                = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}-adminnsg"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  security_rule {
    name                       = "admin_access"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["9000", "9003", "1438", "1440", "1452"]
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

resource "azurerm_network_interface" "jbnic" {
  name                = "${var.AppName}-jb-nic"
  location            = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  ip_configuration {
    name                          = "jbconfiguration"
    subnet_id                     = "${azurerm_subnet.admin-subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "jb-ip" {
  name                = "jb-${azurerm_virtual_machine.jb.name}-Gate-IP"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"
  location            = "${var.azure_region}"
  allocation_method   = "Dynamic"
  sku                 ="basic"
  tags {
    environment = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}"
  }
}

resource "azurerm_virtual_machine" "jb" {
  name                  = "${var.AppName}-jb-vm"
  location              = "${azurerm_resource_group.pdw-rg.location}"
  resource_group_name   = "${azurerm_resource_group.pdw-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jbnic.id}"]
  vm_size               = "Standard_DS1_v2"

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
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  tags {
    environment = "${var.DeploymentLifecycle}-${var.AppName}-${var.LOB}"
  }
}


