data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2" {
  count         = var.instance_cnt
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.type
  key_name      = var.key_name
  vpc_security_group_ids = [
    "${var.sg_ec2_id}"
  ]
  subnet_id                   = element(var.subnets.*.id, count.index % length(var.subnets))
  associate_public_ip_address = "true"

  # user_data属性を追加してシェルスクリプトを指定
  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "${var.env}-${var.system}-web"
    Cost = "${var.system}"
  }
}
