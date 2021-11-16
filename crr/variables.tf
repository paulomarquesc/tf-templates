variable "location" {
  description = "The Azure location where all resources in this example should be created."
}

variable "location-secondary" {
  description = "The Azure location where the secondary volume will be created."
}

variable "prefix" {
  description = "The prefix used for all resources used by this NetApp Volume"
}
