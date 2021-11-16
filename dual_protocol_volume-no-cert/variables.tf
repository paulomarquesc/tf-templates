variable "location" {
  description = "The Azure location where all resources in this example should be created."
}

variable "prefix" {
  description = "The prefix used for all resources used by this NetApp Volume"
}

variable "password" {
  description = "Password to be used by AD object"
}

variable "subnet_id" {
  description = "Subnet to attach the volume to"
}
