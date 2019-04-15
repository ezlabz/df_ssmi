data "terraform_remote_state" "pdw" {
  backend = "azurerm"
  config {
      
    storage_account_name = "terraformstatestg"
    container_name       = "terraform-state"
    key                  = "test.pdw.tfstate"
    access_key           ="CMC049gW14ma/hd/Ccv1vgovdsgAVQFKwS1FjRA33VDagTaNt3tDyIXp4U4ExZJ4F+mo6i+Zk3fPsg3VjF790w=="
  }
}