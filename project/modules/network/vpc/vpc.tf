#1 VPC作成
resource "aws_vpc" "project-vpc" {
  cidr_block = var.vpc_prefix
  tags = {
    Name = "${var.tag_name_prefix}-vpc"
  }
}

resource "aws_subnet" "project-subnet1" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = var.subnet_prefix[0].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.subnet_prefix[0].name}"
  }
}

resource "aws_subnet" "project-subnet2" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = var.subnet_prefix[1].cidr_block
  availability_zone = var.subnet_prefix[1].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.subnet_prefix[1].name}"
  }
}
