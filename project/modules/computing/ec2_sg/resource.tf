resource "aws_security_group" "project_security_group" {
  name        = "${var.tag_name_prefix}-${var.protocol_name}-sg"
  description = "allow ${var.protocol_name} sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_name_prefix}-${var.protocol_name}-sg"
  }
}
