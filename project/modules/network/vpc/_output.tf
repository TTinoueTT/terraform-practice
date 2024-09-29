output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.project_vpc.id
}
output "route_table_id" {
  description = "The ID of the Route Table"
  value       = aws_route_table.project_public_route_table.id
}
