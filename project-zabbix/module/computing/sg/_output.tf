output "sg_ec2_id" {
  value = aws_security_group.sg_ec2.id
}
output "sg_elb_id" {
  value = aws_security_group.sg_elb.id
}
