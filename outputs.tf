output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = module.asg.load_balancer_dns
  
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.rds.db_endpoint
  sensitive = true
}

output "rds_replica_endpoint" {
  description = "The endpoint of the RDS read replica"
  value       = module.rds.db_replica_endpoint
  sensitive = true
}


output "nat_gateway_ip" {
  description = "The Elastic IP of the NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling group"
  value       = module.asg.autoscaling_group_arn
}
