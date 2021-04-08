variable "subnet" {
  description = "CIDR block for the region subnet"
  default     = "10.0.1.0/24"
}

variable "manual_nat_ip_address_count" {
  description = "Number of manual IP address to configure for the NAT router"
  default     = 0
}
