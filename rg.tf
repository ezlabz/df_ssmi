# Create a resource group
resource "azurerm_resource_group" "pdw-rg" {
  name     = "${var.AppName}${var.LOB}pocpdwrg"
  location = "${var.azure_region}"
}

resource "random_string" "password" {
  length = 12
  special = true
  override_special = "/@\" "
}

output "password" {
  value = "${random_string.password.result}"
}