variable "vpc_prefix" {
  description = "cidr block for the vpc"
  default     = "10.0.1.0/24"
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
  default     = "10.0.1.0/24"
}
