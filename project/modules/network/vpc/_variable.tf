variable "tag_name_prefix" {
  description = "prefix for resource name tags (cabab case)"
  type        = string
}

variable "vpc_prefix" {
  description = "cidr block for the vpc"
  default     = "10.0.0.0/16"
  type        = string
}

variable "public_subnet_prefix" {
  description = "cidr block for the subnet"
  default = [
    { cidr_block = "10.0.1.0/24", availability_zone = "ap-northeast-1a", name = "public-subnet-1a" },
    { cidr_block = "10.0.2.0/24", availability_zone = "ap-northeast-1c", name = "public-subnet-1c" }
  ]

  type = list(object(
    { cidr_block = string, availability_zone = string, name = string }
  ))

}


