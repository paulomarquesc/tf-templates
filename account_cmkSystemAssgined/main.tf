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
	tenant_id = azurerm_netapp_account.example.identity.0.tenant_id
	object_id = data.azurerm_client_config.current.object_id

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

	encryption {
		key_vault_key_id = azurerm_key_vault_key.example.versionless_id
	}

	depends_on = [
		azurerm_key_vault_access_policy.example-systemassigned
	]
}
