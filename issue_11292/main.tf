provider "azurerm" {
  features {}
}

data "azurerm_netapp_volume" "volume" {
  account_name        = "${var.account_name}"
  name                = "${var.volume_name}"
  pool_name           = "${var.pool_name}"
  resource_group_name = "${var.resource_group}"
}