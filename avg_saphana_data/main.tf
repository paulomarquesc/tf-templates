provider "azurerm" {
  features {}
}

data "azurerm_netapp_volume_group" "test" {
  resource_group_name    = "pmctest6-resources"
  account_name           = "pmctest6-netapp-account"
  name                   = "pmctest6-netapp-volumegroup"
}

output "location" {
  value = data.azurerm_netapp_volume_group.test.location
}

output "volume_group" {
  value = data.azurerm_netapp_volume_group.test
}

output "first_volume_name" {
  value = data.azurerm_netapp_volume_group.test.volume[0].name
}

output "second_volume_name" {
  value = data.azurerm_netapp_volume_group.test.volume[1].name
}

