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

# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"

#   name = var.ec2_instance_name

#   ami                    = var.ec2_instance_ami
#   instance_type          = var.ec2_instance_instance_type
#   key_name               = var.ec2_instance_key_name
#   vpc_security_group_ids = [module.web_server_sg.security_group_id, module.ssh_sg.security_group_id]
#   subnet_id              = module.vpc.public_subnets[1]

#   user_data = "${file("install_web_server.sh")}"

#   tags = var.ec2_instance_tags

# }


# for db security group
# module "db_sg" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = var.db_sg_name
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = local.db_sg_ingress_with_source_security_group_id
# }

# module "db" {
#   source  = "terraform-aws-modules/rds/aws"

#   identifier = local.db_identifier

#   engine            = local.db_engine
#   engine_version    = local.db_engine_version
#   instance_class    = local.db_instance_class
#   allocated_storage = local.db_allocated_storage
#   db_name  = local.db_db_name
#   username = local.db_username
#   password = local.db_password
#   port     = local.db_port
#   major_engine_version = local.db_major_engine_version
#   family = local.db_family
#   multi_az = local.db_multi_az
#   # skip creating final snapshot, otherwise terraform could not notice the snaptshot which block the whole destroy
#   skip_final_snapshot = local.db_skip_final_snapshot
#   vpc_security_group_ids = [module.db_sg.security_group_id]
#   tags = var.db_tags
#   # DB subnet group
#   create_db_subnet_group = local.db_create_db_subnet_group
#   subnet_ids = module.vpc.private_subnets
  
# }

## Creat loadbalancer ALB
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = local.alb_name

  load_balancer_type = local.alb_load_balancer_type

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.web_server_sg.security_group_id]

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = local.alb_target_groups

  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #     target_group_index = 0
  #   }
  # ]

  http_tcp_listeners = local.alb_http_tcp_listeners

  tags = local.alb_tags

}


## create auto scalling

# for asg security group
module "asg_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = local.asg_sg_name
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = local.asg_sg_ingress_with_source_security_group_id
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = local.asg_name

  # combine ASG with loadbalancer alb through target_group_arns
  target_group_arns = module.alb.target_group_arns

  min_size                  = local.asg_min_size
  max_size                  = local.asg_max_size
  desired_capacity          = local.asg_desired_capacity
  wait_for_capacity_timeout = local.asg_wait_for_capacity_timeout
  health_check_type         = local.asg_health_check_type
  vpc_zone_identifier       = module.vpc.private_subnets

  instance_refresh = local.asg_instance_refresh

  # Launch configuration
  launch_template_name = local.asg_lc_name

  # image_id          = local.asg_image_id
  # instance_type     = local.asg_instance_type
  # key_name          = var.ec2_instance_key_name

  image_id               = var.ec2_instance_ami
  instance_type          = var.ec2_instance_instance_type
  key_name               = var.ec2_instance_key_name

  # user_data = base64encode(file("install_web_server.sh"))
  user_data = filebase64("${path.module}/install_web_server.sh")


  security_groups = [module.asg_sg.security_group_id]

  tags = local.asg_tags
}