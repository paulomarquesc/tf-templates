provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z",
    SkipNRMSNSG   = "true"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "example-delegated" {
  name                 = "${var.prefix}-delegated-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.6.1.0/24"]

  delegation {
    name = "exampledelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "example-non-delegated" {
  name                 = "${var.prefix}-non-delegated-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.6.0.0/24"]
}

resource "azurerm_key_vault" "example" {
  name                            = "${var.prefix}anfakv"
  location                        = azurerm_resource_group.example.location
  resource_group_name             = azurerm_resource_group.example.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  tenant_id                       = var.tenant_id

  sku_name = "standard"

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z"
  }
}

resource "azurerm_key_vault_access_policy" "example-currentuser" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = azurerm_netapp_account.example.identity.0.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "example" {
  name         = "${var.prefix}anfenckey"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.example-currentuser
  ]
}

resource "azurerm_private_endpoint" "example" {
  name                = "${var.prefix}-pe-akv"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.example-non-delegated.id

  private_service_connection {
    name                           = "${var.prefix}-pe-sc-akv"
    private_connection_resource_id = azurerm_key_vault.example.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
  }
}

resource "azurerm_netapp_account" "example" {
  name                = "${var.prefix}-netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  identity {
    type = "SystemAssigned"
  }

  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
  }
}

resource "azurerm_key_vault_access_policy" "example-systemassigned" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = azurerm_netapp_account.example.identity.0.tenant_id
  object_id    = azurerm_netapp_account.example.identity.0.principal_id

  key_permissions = [
    "Get",
    "Encrypt",
    "Decrypt"
  ]
}

resource "azurerm_netapp_account_encryption" "example" {
  netapp_account_id = azurerm_netapp_account.example.id
  system_assigned_identity_principal_id = azurerm_netapp_account.example.identity.0.principal_id
  encryption_key = azurerm_key_vault_key.example.versionless_id
  
  depends_on = [
    azurerm_key_vault_access_policy.example-systemassigned
  ]
}

resource "azurerm_netapp_pool" "example" {
  name                = "${var.prefix}-pool"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example.name
  service_level       = "Standard"
  size_in_tb          = 4

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }

  depends_on = [
    azurerm_netapp_account_encryption.example
  ]
}

resource "azurerm_netapp_volume" "example" {
  name                          = "${var.prefix}-vol"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  account_name                  = azurerm_netapp_account.example.name
  pool_name                     = azurerm_netapp_pool.example.name
  volume_path                   = "${var.prefix}-my-unique-file-path-vol"
  service_level                 = "Standard"
  subnet_id                     = azurerm_subnet.example-delegated.id
  storage_quota_in_gb           = 100
  network_features              = "Standard"
  encryption_key_source         = "Microsoft.KeyVault"
  key_vault_private_endpoint_id = azurerm_private_endpoint.example.id

  export_policy_rule {
    rule_index          = 1
    allowed_clients     = ["0.0.0.0/0"]
    protocols_enabled   = ["NFSv3"]
    unix_read_only      = false
    unix_read_write     = true
    root_access_enabled = true
  }

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }

  depends_on = [
    azurerm_netapp_account_encryption.example,
    azurerm_private_endpoint.example
  ]
}
