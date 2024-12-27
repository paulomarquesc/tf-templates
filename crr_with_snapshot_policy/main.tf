provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "example_primary" {
  name                = "${var.prefix}-virtualnetwork-primary"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "example_primary" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example_primary.name
  address_prefixes     = ["10.10.2.0/24"]

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_virtual_network" "example_secondary" {
  name                = "${var.prefix}-virtualnetwork-secondary"
  location            = var.location-secondary
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["11.0.0.0/16"]
}

resource "azurerm_subnet" "example_secondary" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example_secondary.name
  address_prefixes     = ["11.0.2.0/24"]

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_account" "example_primary" {
  name                = "${var.prefix}-netappaccount-primary"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_netapp_snapshot_policy" "example_primary" {
  name                = "${var.prefix}-snapshotpolicy-primary"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example_primary.name
  enabled             = true

  hourly_schedule {
    snapshots_to_keep = 4
    minute            = 15
  }

  daily_schedule {
    snapshots_to_keep = 2
    hour              = 20
    minute            = 15
  }

  weekly_schedule {
    snapshots_to_keep = 1
    days_of_week      = ["Monday", "Friday"]
    hour              = 23
    minute            = 0
  }

  monthly_schedule {
    snapshots_to_keep = 1
    days_of_month     = [1, 15, 20, 30]
    hour              = 5
    minute            = 45
  }
}

resource "azurerm_netapp_snapshot_policy" "example_secondary" {
  name                = "${var.prefix}-snapshotpolicy-secondary"
  location            = var.location-secondary
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example_secondary.name
  enabled             = true

  hourly_schedule {
    snapshots_to_keep = 4
    minute            = 15
  }

  daily_schedule {
    snapshots_to_keep = 2
    hour              = 20
    minute            = 15
  }

  weekly_schedule {
    snapshots_to_keep = 1
    days_of_week      = ["Monday", "Friday"]  
    hour              = 23
    minute            = 0
  }

  monthly_schedule {
    snapshots_to_keep = 1
    days_of_month     = [1, 15, 20, 30]
    hour              = 5
    minute            = 45
  }
}


resource "azurerm_netapp_account" "example_secondary" {
  name                = "${var.prefix}-netappaccount-secondary"
  location            = var.location-secondary
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_netapp_pool" "example_primary" {
  name                = "${var.prefix}-netapppool-primary"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example_primary.name
  service_level       = "Standard"
  size_in_tb          = 4
}

resource "azurerm_netapp_pool" "example_secondary" {
  name                = "${var.prefix}-netapppool-secondary"
  location            = var.location-secondary
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example_secondary.name
  service_level       = "Standard"
  size_in_tb          = 4
}

resource "azurerm_netapp_volume" "example_primary" {
  lifecycle {
    prevent_destroy = true
  }

  name                = "${var.prefix}-netappvolume-primary"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example_primary.name
  pool_name           = azurerm_netapp_pool.example_primary.name
  volume_path         = "${var.prefix}-netappvolume"
  service_level       = "Standard"
  protocols           = ["NFSv3"]
  subnet_id           = azurerm_subnet.example_primary.id
  storage_quota_in_gb = 100

  export_policy_rule  {
   rule_index        = 1
   allowed_clients   = ["0.0.0.0/0"]
   protocols_enabled = ["NFSv3"]
   unix_read_only    = false
   unix_read_write   = true
  }

  data_protection_snapshot_policy {
    snapshot_policy_id = azurerm_netapp_snapshot_policy.example_primary.id
  }

}

resource "azurerm_netapp_volume" "example_secondary" {
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [ azurerm_netapp_volume.example_primary ]

  name                = "${var.prefix}-netappvolume-secondary"
  location            = var.location-secondary
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example_secondary.name
  pool_name           = azurerm_netapp_pool.example_secondary.name
  volume_path         = "${var.prefix}-netappvolume-secondary"
  service_level       = "Standard"
  protocols           = ["NFSv3"]
  subnet_id           = azurerm_subnet.example_secondary.id
  storage_quota_in_gb = 100

  export_policy_rule  {
   rule_index        = 1
   allowed_clients   = ["0.0.0.0/0"]
   protocols_enabled = ["NFSv3"]
   unix_read_only    = false
   unix_read_write   = true
  }

  data_protection_replication {
      endpoint_type             = "dst" # supported values are "src" and "dst"
      remote_volume_location    = azurerm_resource_group.example.location
      remote_volume_resource_id = azurerm_netapp_volume.example_primary.id
      replication_frequency     = "10minutes" #  supported values are "10minutes", "hourly" and "daily"
  }

  data_protection_snapshot_policy {
    snapshot_policy_id = azurerm_netapp_snapshot_policy.example_secondary.id
  }


}
