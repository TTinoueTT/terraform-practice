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
