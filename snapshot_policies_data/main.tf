provider "azurerm" {
  features {}
}

data "azurerm_netapp_snapshot_policy" "example" {
  name                = var.name
  resource_group_name = var.resource_group_name
  account_name        = var.account_name
}

output "location" {
  value = data.azurerm_netapp_snapshot_policy.example.location
}

output "id" {
  value = data.azurerm_netapp_snapshot_policy.example.id
}

output "resource_group_name" {
  value = data.azurerm_netapp_snapshot_policy.example.resource_group_name
}

output "account_name" {
  value = data.azurerm_netapp_snapshot_policy.example.account_name
}

output "name" {
  value = data.azurerm_netapp_snapshot_policy.example.name
}

output "enabled" {
  value = data.azurerm_netapp_snapshot_policy.example.enabled
}

output "hourly_schedule" {
  value = data.azurerm_netapp_snapshot_policy.example.hourly_schedule
}

output "daily_schedule" {
  value = data.azurerm_netapp_snapshot_policy.example.daily_schedule
}

output "weekly_schedule" {
  value = data.azurerm_netapp_snapshot_policy.example.weekly_schedule
}

output "monthly_schedule" {
  value = data.azurerm_netapp_snapshot_policy.example.monthly_schedule
}
