
resource "aws_security_group" "sg-ec2" {
  name        = "${var.env}-${var.system}-sg-http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-elb.id]
    cidr_blocks     = [var.my_ip]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-${var.system}-sg-http"
    Cost = "${var.system}"
  }
}

resource "aws_security_group" "sg-elb" {
  name        = "${var.env}-${var.system}-sg-elb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-${var.system}-sg-elb"
    Cost = "${var.system}"
  }
}

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
  count = var.instance_cnt
  ami   = data.aws_ami.ubuntu.id
  # ami           = var.ami
  instance_type = var.type
  key_name      = var.key_name
  vpc_security_group_ids = [
    "${aws_security_group.sg-ec2.id}"
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
