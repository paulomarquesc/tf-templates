#!/bin/bash

# Importing all rersources of main.tf

# Import Azure Resource Group
terraform import -var location=westus -var prefix=test1 azurerm_resource_group.example /subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/test1-resources 

# Import Azure Virtual Network
terraform import -var location=westus -var prefix=test1 azurerm_virtual_network.example /subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/test1-resources/providers/Microsoft.Network/virtualNetworks/test1-virtualnetwork

# Import Azure Subnet
terraform import -var location=westus -var prefix=test1 azurerm_subnet.example /subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/test1-resources/providers/Microsoft.Network/virtualNetworks/test1-virtualnetwork/subnets/test1-subnet

# Import Azure NetApp Account
terraform import -var location=westus -var prefix=test1 azurerm_netapp_account.example /subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/test1-resources/providers/Microsoft.NetApp/netAppAccounts/test1-netappaccount

# Import Azure NetApp Pool
terraform import -var location=westus -var prefix=test1 azurerm_netapp_pool.example /subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/test1-resources/providers/Microsoft.NetApp/netAppAccounts/test1-netappaccount/capacityPools/test1-netapppool

# Import Azure NetApp Volume
terraform import -var location=westus -var prefix=test1 azurerm_netapp_volume.example /subscriptions/66bc9830-19b6-4987-94d2-0e487be7aa47/resourceGroups/test1-resources/providers/Microsoft.NetApp/netAppAccounts/test1-netappaccount/capacityPools/test1-netapppool/volumes/test1-netappvolume

