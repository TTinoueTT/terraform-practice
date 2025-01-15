output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "subnets" {
  description = "The ID of the Public Subnet"
  value       = aws_subnet.public
}
