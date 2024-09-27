# global に設定する変数
variable "aws_region" {
  description = "aws provider region"
  type        = string
}

variable "aws_access_key" {
  description = "aws provider access key"
  type        = string
}

variable "aws_secret_key" {
  description = "aws provider secret key"
  type        = string
}
