variable "managed_zone_name" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "fqdn_mtls" {
  default = "UNDEFINED"
}

variable "lb_ip" {
  type = string
}
