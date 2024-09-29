variable "tag_name_prefix" {
  description = "prefix for resource name tags (cabab case)"
  type        = string
}

variable "ingress_rule" {
  description = "cidr block for the subnet"
  default = [
    { cidr_ipv4 = "10.0.0.0/8", from_port = 80, ip_protocol = "tcp", to_port = 80 }
  ]

  type = list(object(
    { cidr_ipv4 = string, from_port = number, ip_protocol = string, to_port = number }
  ))

}

variable "security_group_id" {
  description = "The ID of the Security Group where ingress rule will be created"
  type        = string
}
