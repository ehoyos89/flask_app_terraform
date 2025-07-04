
# Salida para el DNS del balanceador de carga.
# Descripción: El nombre DNS del balanceador de carga.
output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

# Salida para el ARN del grupo de Auto Scaling.
# Descripción: El ARN del grupo de Auto Scaling.
output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling group"
  value       = aws_autoscaling_group.main.arn 
}

