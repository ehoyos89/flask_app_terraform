# Salida para el ID de la VPC.
# Descripción: El ID de la VPC.
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "flow_log_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_log ? aws_cloudwatch_log_group.flow_logs[0].name : ""
}


# Salida para la IP de la NAT Gateway.
# Descripción: La IP elástica de la NAT Gateway.
output "nat_gateway_ip" {
  description = "The Elastic IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip 
}

# Salida para el ID del Internet Gateway.
# Descripción: El ID del Internet Gateway.
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
  
}
