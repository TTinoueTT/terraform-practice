#4 サブネット作成
resource "aws_subnet" "project_pubric_subnet1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_prefix[0].cidr_block
  availability_zone = var.public_subnet_prefix[0].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.public_subnet_prefix[0].name}"
  }
}

resource "aws_subnet" "project_pubric_subnet2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_prefix[1].cidr_block
  availability_zone = var.public_subnet_prefix[1].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.public_subnet_prefix[1].name}"
  }
}

#5 サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "project_public_association1" {
  subnet_id      = aws_subnet.project_pubric_subnet1.id
  route_table_id = var.route_table_id
}
resource "aws_route_table_association" "project_public_association2" {
  subnet_id      = aws_subnet.project_pubric_subnet2.id
  route_table_id = var.route_table_id
}
