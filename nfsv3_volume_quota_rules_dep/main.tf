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
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "3001"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualGroupQuota"
}

resource "azurerm_netapp_volume_quota_rule" "example2" {
  name                   = "${var.prefix}-quota-rule-2"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2001"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example1 ]
}

resource "azurerm_netapp_volume_quota_rule" "example3" {
  name                   = "${var.prefix}-quota-rule-3"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_size_in_kib      = 1024
  quota_type             = "DefaultUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-1" {
  name                   = "${var.prefix}-quota-rule-2-1"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2101"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example3 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-2" {
  name                   = "${var.prefix}-quota-rule-2-2"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2201"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-1 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-3" {
  name                   = "${var.prefix}-quota-rule-2-3"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2301"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-2 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-4" {
  name                   = "${var.prefix}-quota-rule-2-4"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2401"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-3 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-5" {
  name                   = "${var.prefix}-quota-rule-2-5"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2501"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-4 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-6" {
  name                   = "${var.prefix}-quota-rule-2-6"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2601"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-5 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-7" {
  name                   = "${var.prefix}-quota-rule-2-7"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2701"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-6 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-8" {
  name                   = "${var.prefix}-quota-rule-2-8"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2801"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-7 ]
}

resource "azurerm_netapp_volume_quota_rule" "example2-9" {
  name                   = "${var.prefix}-quota-rule-2-9"
  location               = azurerm_resource_group.example.location
  resource_group_name    = azurerm_resource_group.example.name
  account_name           = azurerm_netapp_account.example.name
  pool_name              = azurerm_netapp_pool.example.name
  volume_name            = azurerm_netapp_volume.example.name
  quota_target           = "2901"
  quota_size_in_kib      = 1024
  quota_type             = "IndividualUserQuota"

  depends_on = [ azurerm_netapp_volume_quota_rule.example2-8 ]
}

# resource "azurerm_netapp_volume_quota_rule" "example2-1" {
#   name                   = "${var.prefix}-quota-rule-2-1"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_target           = "96fcd20a-55a4-41ab-b211-567c3746d7fb"
#   quota_size_in_kib      = 1024
#   quota_type             = "IndividualUserQuota"
# }

// Error - Needs to check volume type if NFS/SMB for quota target
# ╷
# │ Error: creating Volume Quota Rule (Subscription: "66bc9830-19b6-4987-94d2-0e487be7aa47"
# │ Resource Group Name: "quotas-tst-1-resources"
# │ Net App Account Name: "quotas-tst-1-netappaccount"
# │ Capacity Pool Name: "quotas-tst-1-netapppool"
# │ Volume Name: "quotas-tst-1-netappvolume"
# │ Volume Quota Rule Name: "quotas-tst-1-quota-rule-2-1"): polling after Create: polling failed: the Azure API returned the following error:
# │
# │ Status: "Failed"
# │ Code: "BadRequest"
# │ Message: "Error creating QuotaRules. Error creating quota rule - quotaTarget is invalid. Please pass numeric value for quotaTarget in range [0, 4294967295] for NFS volumes"
# │ Activity Id: ""
# │
# │ ---
# │
# │ API Response:
# │
# │ ----[start]----
# │ {"id":"/subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/providers/Microsoft.NetApp/locations/eastus/operationResults/954f9854-935b-498f-905e-ad2886b96678","name":"954f9854-935b-498f-905e-ad2886b96678","status":"Failed","startTime":"2023-08-18T17:15:38.9697634Z","endTime":"2023-08-18T17:15:39.6677483Z","percentComplete":100.0,"properties":{"resourceName":"/subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/quotas-tst-1-resources/providers/Microsoft.NetApp/netAppAccounts/quotas-tst-1-netappaccount/capacityPools/quotas-tst-1-netapppool/volumes/quotas-tst-1-netappvolume/volumeQuotaRules/quotas-tst-1-quota-rule-2-1","action":"CREATE"},"error":{"code":"BadRequest","message":"Error creating QuotaRules. Error creating quota rule - quotaTarget is invalid. Please pass numeric value for quotaTarget in range [0, 4294967295] for NFS volumes","details":[{"code":"ErrorPerformingActionOnResource","message":"Error creating QuotaRules. Error creating quota rule - quotaTarget is invalid. Please pass numeric value for quotaTarget in range [0, 4294967295] for NFS volumes"}]}}
# │ -----[end]-----




# resource "azurerm_netapp_volume_quota_rule" "example3" {
#   name                   = "${var.prefix}-quota-rule-3"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_size_in_kib      = 1024
#   quota_type             = "DefaultUserQuota"
# }

# resource "azurerm_netapp_volume_quota_rule" "example4" {
#   name                   = "${var.prefix}-quota-rule-4"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_size_in_kib      = 1024
#   quota_type             = "DefaultGroupQuota"
# }

# resource "azurerm_netapp_volume_quota_rule" "example5" {
#   name                   = "${var.prefix}-quota-ignored-tg-rule-5"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_target           = "5001"
#   quota_size_in_kib      = 1024
#   quota_type             = "DefaultGroupQuota"
# }

# Error - Needs to check default quota types and don't pass quota target
# ╷
# │ Error: creating Volume Quota Rule (Subscription: "66bc9830-19b6-4987-94d2-0e487be7aa47"
# │ Resource Group Name: "quotas-tst-1-resources"
# │ Net App Account Name: "quotas-tst-1-netappaccount"
# │ Capacity Pool Name: "quotas-tst-1-netapppool"
# │ Volume Name: "quotas-tst-1-netappvolume"
# │ Volume Quota Rule Name: "quotas-tst-1-quota-ignored-tg-rule-5"): performing Create: unexpected status 400 with error: InvalidDefaultUserGroupQuotaTarget: quotaTarget cannot be specified for Default user/group quotaType. To create this quotaRule, change quotaType to IndividualUserQuota or IndividualGroupQuota.
# │
# │   with azurerm_netapp_volume_quota_rule.example5,
# │   on main.tf line 130, in resource "azurerm_netapp_volume_quota_rule" "example5":
# │  130: resource "azurerm_netapp_volume_quota_rule" "example5" {
# │
# │ creating Volume Quota Rule (Subscription: "66bc9830-19b6-4987-94d2-0e487be7aa47"
# │ Resource Group Name: "quotas-tst-1-resources"
# │ Net App Account Name: "quotas-tst-1-netappaccount"
# │ Capacity Pool Name: "quotas-tst-1-netapppool"
# │ Volume Name: "quotas-tst-1-netappvolume"
# │ Volume Quota Rule Name: "quotas-tst-1-quota-ignored-tg-rule-5"): performing Create: unexpected status 400 with error:
# │ InvalidDefaultUserGroupQuotaTarget: quotaTarget cannot be specified for Default user/group quotaType. To create this quotaRule, change quotaType to
# │ IndividualUserQuota or IndividualGroupQuota.
# ╵


# resource "azurerm_netapp_volume_quota_rule" "example5-1" {
#   name                   = "${var.prefix}-quota-ignored-tg-rule-5-1"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_target           = "7001"
#   quota_size_in_kib      = 1024
#   quota_type             = "DefaultGroupQuota"
# }

# resource "azurerm_netapp_volume_quota_rule" "example6" {
#   name                   = "${var.prefix}-quota-invalid-rule-6"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_target           = "5001111111111111111111111111111111111111111111111111111111"
#   quota_size_in_kib      = 1024
#   quota_type             = "IndividualUserQuota"
# }

# resource "azurerm_netapp_volume_quota_rule" "example7" {
#   name                   = "${var.prefix}-quota-invalid-rule-7"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_target           = "abc1111"
#   quota_size_in_kib      = 1024
#   quota_type             = "IndividualUserQuota"
# }

# resource "azurerm_netapp_volume_quota_rule" "example2-2" {
#   name                   = "${var.prefix}-quota-rule-2-2"
#   location               = azurerm_resource_group.example.location
#   resource_group_name    = azurerm_resource_group.example.name
#   account_name           = azurerm_netapp_account.example.name
#   pool_name              = azurerm_netapp_pool.example.name
#   volume_name            = azurerm_netapp_volume.example.name
#   quota_target           = "96fcd20a55a441abb211567c3746d7fb"
#   quota_size_in_kib      = 1024
#   quota_type             = "IndividualUserQuota"
# }
