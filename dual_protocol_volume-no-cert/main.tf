# PLan example
# terraform plan -var location=westus -var password="$(Get-Credential).GetNetworkCredential().Password" -var prefix="pmctest21" -var subnet_id="/subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/anf-smb-rg/providers/Microsoft.Network/virtualNetworks/westus-vnet01/subnets/anf-sn" -out="D:\data\git\_anf\terraform\crr\plan"

# terraform {
#   required_providers {
#     azurerm = {
#       source = "hashicorp/azurerm"
#       version = "2.48.0"
#     }
#   }
# }

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_netapp_account" "example" {
  name                = "${var.prefix}-netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  active_directory {
    username            = "pmcadmin"
    password            = var.password
    smb_server_name     = "SMBSERVER"
    dns_servers         = ["10.2.0.4"]
    domain              = "anf.local"
  }
}

resource "azurerm_netapp_pool" "example" {
  name                = "${var.prefix}-netapppool"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example.name
  service_level       = "Standard"
  size_in_tb          = 4
}

resource "azurerm_netapp_volume" "example" {
  lifecycle {
    prevent_destroy = true
  }

  name                = "${var.prefix}-netappvolume-dual"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example.name
  pool_name           = azurerm_netapp_pool.example.name
  volume_path         = "${var.prefix}-netappvolume-dual"
  service_level       = "Standard"
  protocols           = ["CIFS","NFSv3"]
  subnet_id           = var.subnet_id
  storage_quota_in_gb = 100
  security_style      = "Ntfs"

  export_policy_rule {
    rule_index = 1
    allowed_clients = ["0.0.0.0/0"]
    protocols_enabled = [ "NFSv3" ]
    unix_read_write = true
  }
}
