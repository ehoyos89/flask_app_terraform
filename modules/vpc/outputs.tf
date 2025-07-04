# Salida para el ID de la VPC.
# Descripción: El ID de la VPC.
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Salida para los IDs de las subredes públicas.
# Descripción: Los IDs de las subredes públicas.
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public.*.id
}

# Salida para los IDs de las subredes privadas.
# Descripción: Los IDs de las subredes privadas.
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private.*.id
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
