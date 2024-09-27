#1 VPC作成
resource "aws_vpc" "project-vpc" {
  cidr_block = var.vpc_prefix
  tags = {
    Name = "project-vpc"
  }
}
