variable "fqdn" {
  type = string
}

variable "fqdn_mtls" {
  default = "UNDEFINED"
}

variable "lb_ip" {
  type = string
}

variable "ttl" {
  default = 300
}
