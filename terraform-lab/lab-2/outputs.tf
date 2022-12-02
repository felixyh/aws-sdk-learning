output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "ec2_instance_public_dns" {
  description = "The public DNS name assigned to the instance."
  value = module.ec2_instance.public_dns
}

output "db_db_instance_endpoint" {
  description = "The connection endpoint"
  value = module.db.db_instance_endpoint
  
}