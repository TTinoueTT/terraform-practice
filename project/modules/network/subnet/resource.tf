#4 サブネット作成
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "project_public_subnet" {
  # length は terraform で用意された関数で配列の長さを返します
  count      = length(var.public_subnet_prefix) # 作成するサブネット数
  vpc_id     = var.vpc_id
  cidr_block = element(var.public_subnet_prefix, count.index)
  # az は data ブロックで取得した配列を参照します。
  availability_zone = data.aws_availability_zones.available.names[count.index % length(var.public_subnet_prefix)]
  tags = {
    Name = "${var.tag_name_prefix}-pub-subnet${count.index + 1}"
  }
}
resource "aws_route_table_association" "project_public_association" {
  count          = length(var.public_subnet_prefix)
  subnet_id      = element(aws_subnet.project_public_subnet.*.id, count.index)
  route_table_id = var.route_table_id
}
