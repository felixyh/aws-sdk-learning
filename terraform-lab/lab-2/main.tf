provider "aws" {
    region = "us-east-2"

    default_tags {
      tags = {
        Environment = "lab-test"
        Owner = "Felix"
        Project = "AWS-boto3-SDK"

      }
    }
  
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = var.vpc_name
    cidr = var.vpc_cidr

    azs = var.vpc_azs
    public_subnets = var.vpc_public_subnets
    private_subnets = var.vpc_private_subnets

    enable_nat_gateway = var.vpc_enable_nat_gateway
    single_nat_gateway = var.vpc_single_nat_gateway
    one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

    enable_dns_hostnames = var.vpc_enable_dns_hostnames



    tags = var.vpc_tags
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = local.web_server_sg_name
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.web_server_sg_ingress_cidr_blocks

}

module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"
  name = local.ssh_sg_name
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = var.ssh_sg_ingress_cidr_blocks
  
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = var.ec2_instance_name

  ami                    = var.ec2_instance_ami
  instance_type          = var.ec2_instance_instance_type
  key_name               = var.ec2_instance_key_name
  vpc_security_group_ids = [module.web_server_sg.security_group_id, module.ssh_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[1]

  user_data = "${file("install_web_server.sh")}"

  tags = var.ec2_instance_tags

}


# for db security group
module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.db_sg_name
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = local.db_sg_ingress_with_source_security_group_id
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = local.db_identifier

  engine            = local.db_engine
  engine_version    = local.db_engine_version
  instance_class    = local.db_instance_class
  allocated_storage = local.db_allocated_storage

  db_name  = local.db_db_name
  username = local.db_username
  password = local.db_password
  port     = local.db_port

  major_engine_version = local.db_major_engine_version
  family = local.db_family

  vpc_security_group_ids = [module.db_sg.security_group_id]

  tags = var.db_tags

  # DB subnet group
  create_db_subnet_group = local.db_create_db_subnet_group
  subnet_ids             = module.vpc.public_subnets

}