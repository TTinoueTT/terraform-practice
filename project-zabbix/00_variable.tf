variable "aws_region" {
  description = "アクセスするリージョン"
  default     = "ap-northeast-1"
  type        = string
}

variable "system" {
  description = "タグに使用するこの基盤のシステム名称(任意)"
  type        = string
}
variable "env" {
  description = "タグに使用する環境の名称(dev|stg|prd)"
  default     = "dev"
  type        = string
}
variable "my_ip" {
  description = "セキュリティグループで許可する自分の IP"
  type        = string
}
variable "instance_cnt" {
  description = "作成するインスタンスの数"
  type        = number
}
variable "ami" {
  description = "作成するインスタンスの ami"
  type        = string
}
variable "type" {
  description = "作成するインスタンスのタイプ"
  type        = string
}
variable "key_name" {
  description = "インスタンスに紐付けるキーペア"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC の CIDR ブロック"
  type        = string
}
variable "cidr_public" {
  description = "サブネットの CIDR ブロック"
  type        = list(string)
}
