#1 VPC作成
resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_prefix
  tags = {
    Name = "${var.tag_name_prefix}-vpc"
  }
}

#2 インターネットゲートウェイ作成
resource "aws_internet_gateway" "project_gateway" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-gateway"
  }
}

#3 ルートテーブル作成
resource "aws_route_table" "project_public_route_table" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    # すべてのインターネットアドレスを許可する
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_gateway.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project_gateway.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-public-route-table"
  }
}

resource "aws_subnet" "project_pubric_subnet1" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.public_subnet_prefix[0].cidr_block
  availability_zone = var.public_subnet_prefix[0].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.public_subnet_prefix[0].name}"
  }
}

#4 サブネット作成
resource "aws_subnet" "project_pubric_subnet2" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.public_subnet_prefix[1].cidr_block
  availability_zone = var.public_subnet_prefix[1].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.public_subnet_prefix[1].name}"
  }
}

#5 サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "project_public_association1" {
  subnet_id      = aws_subnet.project_pubric_subnet1.id
  route_table_id = aws_route_table.project_public_route_table.id
}
resource "aws_route_table_association" "project_public_association2" {
  subnet_id      = aws_subnet.project_pubric_subnet2.id
  route_table_id = aws_route_table.project_public_route_table.id
}
