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

	access_policy {
		tenant_id = var.tenant_id
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

	access_policy {
		tenant_id = var.tenant_id
		object_id = azurerm_user_assigned_identity.example.principal_id
	
		key_permissions = [
		  "Get",
		  "Encrypt",
		  "Decrypt"
		]
	}

	tags = {
		"CreatedOnDate" = "2022-07-08T23:50:21Z"
	}
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
}

resource "azurerm_private_endpoint" "example" {
	name                   = "${var.prefix}-pe-akv"
	location               = azurerm_resource_group.example.location
	resource_group_name    = azurerm_resource_group.example.name
	subnet_id              = azurerm_subnet.example-non-delegated.id

	private_service_connection {
	  name                          = "${var.prefix}-pe-sc-akv"
	  private_connection_resource_id = azurerm_key_vault.example.id
	  is_manual_connection          = false
	  subresource_names             = ["Vault"]
	}
	
	tags = {
		CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
	  }
}

# creating user assgined identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "${var.prefix}-user-assigned-identity"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
  }
}

resource "azurerm_netapp_account" "example" {
  name                = "${var.prefix}-netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.example.id
    ]
  }

  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
  }
}

resource "azurerm_netapp_account_encryption" "example" {
	netapp_account_id = azurerm_netapp_account.example.id
	
	user_assigned_identity_id = azurerm_user_assigned_identity.example.id

	encryption {
		key_vault_key_id = azurerm_key_vault_key.example.versionless_id
	}

	depends_on = [
		azurerm_private_endpoint.example
	]
}