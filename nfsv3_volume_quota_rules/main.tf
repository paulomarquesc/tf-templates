provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location

  tags = {
    "CreatedOnDate" = "2023-08-18T17:44:19.9445791Z",
    "SkipNRMSNSG"   = "true"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-virtualnetwork"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    "CreatedOnDate" = "2023-08-18T17:44:19.9445791Z" 
  }
}

resource "azurerm_subnet" "example" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_account" "example" {
  name                = "${var.prefix}-netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    "CreatedOnDate" = "2023-08-18T17:44:19.9445791Z" 
  }
}

resource "azurerm_netapp_pool" "example" {
  name                = "${var.prefix}-netapppool"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example.name
  service_level       = "Standard"
  size_in_tb          = 4

  tags = {
    "CreatedOnDate" = "2023-08-18T17:44:19.9445791Z" 
  }
}

resource "azurerm_netapp_volume" "example" {
  lifecycle {
    prevent_destroy = true
  }

  name                = "${var.prefix}-netappvolume"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example.name
  pool_name           = azurerm_netapp_pool.example.name
  volume_path         = "${var.prefix}-netappvolume"
  service_level       = "Standard"
  protocols           = ["NFSv3"]
  subnet_id           = azurerm_subnet.example.id
  storage_quota_in_gb = 100

  export_policy_rule {
    rule_index = 1
    allowed_clients = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv3"]
    unix_read_write = true
  }

  tags = {
    "CreatedOnDate" = "2023-08-18T19:35:16.6346340Z"
  }
}

resource "azurerm_netapp_volume_quota_rule" "example1" {
  name                   = "${var.prefix}-quota-rule-1"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "3001"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualGroupQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2" {
  name                   = "${var.prefix}-quota-rule-2"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2001"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example3" {
  name                   = "${var.prefix}-quota-rule-3"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_size_in_kib      = 1024
  quota_type             = "DefaultUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-1" {
  name                   = "${var.prefix}-quota-rule-2-1"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_size_in_kib      = 1024
  quota_type             = "DefaultGroupQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-2" {
  name                   = "${var.prefix}-quota-rule-2-2"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2201"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-3" {
  name                   = "${var.prefix}-quota-rule-2-3"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2301"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-4" {
  name                   = "${var.prefix}-quota-rule-2-4"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2401"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-5" {
  name                   = "${var.prefix}-quota-rule-2-5"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2501"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-6" {
  name                   = "${var.prefix}-quota-rule-2-6"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2601"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-7" {
  name                   = "${var.prefix}-quota-rule-2-7"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2701"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-8" {
  name                   = "${var.prefix}-quota-rule-2-8"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2801"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2-9" {
  name                   = "${var.prefix}-quota-rule-2-9"
  location               = azurerm_resource_group.example.location
  volume_id              = azurerm_netapp_volume.example.id
  quota_target           = "2901"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"
}
