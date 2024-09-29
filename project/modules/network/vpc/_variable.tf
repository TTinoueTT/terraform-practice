variable "tag_name_prefix" {
  description = "prefix for resource name tags (cabab case)"
  type        = string
}

variable "vpc_prefix" {
  description = "cidr block for the vpc"
  default     = "10.0.0.0/16"
  type        = string
}


