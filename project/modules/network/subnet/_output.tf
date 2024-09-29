output "subnet1_id" {
  description = "The ID of the Public Subnet"
  value       = aws_subnet.project_pubric_subnet1.id
}
output "subnet2_id" {
  description = "The ID of the Public Subnet"
  value       = aws_subnet.project_pubric_subnet2.id
}
