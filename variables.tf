# Any varialbes not defined with a default MUST be overriden in a TVAR file.
# If there is a default, the template will use that unless it is overridden in the TVAR file.


# This is the deployment Lifecycle that should be one of the following values.
# - prod
# - qa
# - test
variable "DeploymentLifecycle" {}

# This is the UNIQUE name.  Dashes are allowed However, the AppId will provide the capability to have unique duplicate names.
variable "AppName" {}

# This is the associate/contractor that spun up the instance, or the associate or contractor that should be contacted regarding this AE
variable "Owner" {}

# This is the Line of Business that the AE belongs to for Charge Back purposes.
variable "LOB" {}

# Our Azure Subscription.
variable "azure_subscription_id" {
  #default = "70852e42-7fc8-4af7-9c87-46b76476d106"
  default = "70852e42-7fc8-4af7-9c87-46b76476d106"
}

# The default Azure Region we build in.
variable "azure_region" {
  default = "East US"
}

# The Azure SP(Service Principle) used to authenticate to Azure api
# (This can be create in the azure cli with az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/{SubscriptionID}")
variable "azure_sp" {
  default = "2b041848-44d4-475c-a43d-6f9562ad950a"
}

variable "sql_mi_name" {
  default = "pdw-sql"
}
#analysis_server_name no no dashes allowed for this one
variable "analysis_server_name" {
  default = "pdwaasql"
}

variable "vnet2_address" {
  default = "10.0.0.0/16"
}

variable "stgvnet2_address" {
  default = "10.0.0.0/16"
}