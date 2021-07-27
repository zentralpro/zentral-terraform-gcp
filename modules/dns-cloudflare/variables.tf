variable "api_token" {
  type      = string
  sensitive = true
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

variable "ttl" {
  default = 300
}

variable "proxied" {
  default = true
}
