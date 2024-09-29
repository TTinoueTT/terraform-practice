resource "aws_vpc_security_group_ingress_rule" "project_ingress_rule" {
  security_group_id = var.security_group_id

  cidr_ipv4   = var.ingress_rule.cidr_ipv4
  from_port   = var.ingress_rule.from_port
  ip_protocol = var.ingress_rule.ip_protocol
  to_port     = var.ingress_rule.to_port

  tags = {
    Name = "${var.tag_name_prefix}-${var.ingress_rule.cidr_ipv4}-${var.ingress_rule.from_port}-ingress-rule"
  }
}
