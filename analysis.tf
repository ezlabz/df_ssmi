data "template_file" "analysis_server" {
  template = "${file("./templates/analysis_services.json")}"
}

resource "azurerm_template_deployment" "analysis_server-tpl-deploy" {
  name                = "${var.AppName}${var.LOB}analysisserverdeploy"
  resource_group_name = "${azurerm_resource_group.pdw-rg.name}"

  template_body = "${data.template_file.analysis_server.rendered}"

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters {
    "aasServerName" = "${var.analysis_server_name}"
  }

  deployment_mode = "Incremental"
}

output "storageAccountName" {
  value = "${lookup(azurerm_template_deployment.analysis_server-tpl-deploy.outputs, "storageAccountName")}"
}