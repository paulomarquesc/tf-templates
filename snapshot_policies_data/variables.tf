variable "resource_group_name" {
  description = "Resource group where snapshot policy is located"
  default = "pmctest3-resources"
}

variable "account_name" {
  description = "Account name where snapshot policy was created"
  default = "pmctest3-netappaccount"
}

variable "name" {
  description = "Snapshot Policy name"
  default = "pmctest3-snapshotpolicy"
}

