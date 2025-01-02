resource "aws_security_group" "sg_ec2" {
  name        = "${var.env}-${var.system}-sg-ec2"
  description = "Allow inbound traffic to ec2 instance"
  vpc_id      = var.vpc_id

  # allow from ELB security group
  # ingress {
  #   # from_port       = 80
  #   # to_port         = 80
  #   protocol        = "http"
  #   security_groups = [aws_security_group.sg-elb.id]
  #   cidr_blocks     = [var.my_ip]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-${var.system}-sg-ec2"
    Cost = "${var.system}"
  }
}

resource "aws_security_group" "sg_elb" {
  name        = "${var.env}-${var.system}-sg-elb"
  description = "Allow HTTP inbound traffic from elb"
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
