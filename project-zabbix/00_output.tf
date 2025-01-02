# *********************************
# VPC
# *********************************
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets" {
  description = "The ID of the Public Subnet"
  value       = module.vpc.subnets
}

# *********************************
# Security Group
# *********************************
output "sg_ec2_id" {
  description = "The ID of the Security Group for EC2 instance"
  value       = module.security_group.sg_ec2_id
}

output "sg_elb_id" {
  description = "The ID of the Security Group for ELB"
  value       = module.security_group.sg_elb_id
}

# *********************************
# output "aws_availability_zones_data" {
#   description = "Availability zones data"
#   value       = data.aws_availability_zones.available.names
# }
