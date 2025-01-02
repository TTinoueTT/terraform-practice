resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = var.sg_id

  cidr_ipv4   = var.ingress_rule.cidr_ipv4
  from_port   = var.ingress_rule.from_port
  ip_protocol = var.ingress_rule.ip_protocol
  to_port     = var.ingress_rule.to_port

  tags = {
    Name = "${var.env}-${var.system}-${var.ingress_rule.cidr_ipv4}-${var.ingress_rule.from_port}-ingress-rule"
  }
}
