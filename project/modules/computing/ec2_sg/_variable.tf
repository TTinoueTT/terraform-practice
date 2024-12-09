variable "tag_name_prefix" {
  description = "prefix for resource name tags (kabab case)"
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC where subnets will be created"
  type        = string
}

variable "protocol_name" {
  description = "Traffic protocol http, https, ssh, smtp, etc..."
  type        = string
}
