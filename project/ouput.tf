# *********************************
# VPC
# *********************************
# output "subnet1_id" {
#   description = "The ID of the Public Subnet1"
#   value       = module.subnet.subnet1_id
# }
# output "subnet2_id" {
#   description = "The ID of the Public Subnet2"
#   value       = module.subnet.subnet2_id
# }

output "subnets" {
  description = "The ID of the Public Subnet1"
  value       = module.subnet.subnets
}

# *********************************
# Security Group
# *********************************
output "security_group_http_id" {
  description = "The ID of the Security Group for HTTP"
  value       = module.security_group_http.security_group_id
}

output "security_group_https_id" {
  description = "The ID of the Security Group for HTTPS"
  value       = module.security_group_https.security_group_id
}

output "security_group_ssh_id" {
  description = "The ID of the Security Group for SSH"
  value       = module.security_group_ssh.security_group_id
}

# *********************************
# output "aws_availability_zones_data" {
#   description = "Availability zones data"
#   value       = data.aws_availability_zones.available.names
# }
