output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.project_vpc.id
}
output "subnet1_id" {
  description = "The ID of the Public Subnet"
  value       = aws_subnet.project_pubric_subnet1.id
}
output "subnet2_id" {
  description = "The ID of the Public Subnet"
  value       = aws_subnet.project_pubric_subnet2.id
}
