resource "aws_subnet" "project-subnet" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = var.subnet_prefix[0].availability_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.subnet_prefix[0].name}"
  }
}
