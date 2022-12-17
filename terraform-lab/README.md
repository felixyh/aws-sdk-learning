[TOC]

<img src="https://felixyanghui.synology.me:8441/images/2022/12/02/image-20221129160103938.png" style="zoom:50%;" />

# 1. AWS Technical Essentials - Lab

## 1.1 Lab-1 Topology

![image-20221202103555079](https://felixyanghui.synology.me:8441/images/2022/12/02/image-20221202103555079.png)

### 1.1.1 Create VPC and web server (AWS Console)

- Create VPC (VPC can be accross AZ, but shall be within one region)
- Create Internet Gateway and attach it to the VPC
- Create Subnet (associate with VPC, AZ)
- Create NAT gateway (associate with the subnet)  - depends on IGW created firstly
- Create Route Table
  - By default, a "Main" type route table already created for the VPC.  Edit the route table to associate it with two priviate subnets and add a default route destinated to NAT GW created before, finally rename the route table name as "private route table"
  - Create one more route table: "public route table", associate with two public subnets. and add a default route destinated to Internet GW created before
- Create VPC security group
- Create EC2 - web instance

### 1.1.2 Create VPC and web server (Terraform -  Module)

- main.tf

  ```tcl
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
  
    name        = "web-server"
    description = "Security group for web-server with HTTP ports open within VPC"
    vpc_id      = module.vpc.vpc_id
  
    ingress_cidr_blocks = var.web_server_sg_ingress_cidr_blocks
  
  }
  
  module "ssh_sg" {
    source = "terraform-aws-modules/security-group/aws//modules/ssh"
    name = "ssh"
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
  ```

  

- variables.tf

  ```tcl
  ###
  # define variables for vpc
  ###
  
  variable "vpc_name" {
      description = "Name of VPC"
      type = string
      default = "Lab-VPC"
    
  }
  
  variable "vpc_cidr" {
      description = "CIDR block for VPC"
      type = string
      default = "10.0.0.0/16"
    
  }
  
  variable "vpc_azs" {
      description = "Availability zones for VPC"
      type = list(string)
      default = ["us-east-2a", "us-east-2b"]
    
  }
  
  variable "vpc_private_subnets" {
      description = "Private subnets for VPC"
      type = list(string)
      default = [ "10.0.1.0/24", "10.0.3.0/24" ]
    
  }
  
  variable "vpc_public_subnets" {
      description = "Public subnets for VPC"
      type = list(string)
      default = [ "10.0.0.0/24", "10.0.2.0/24" ]
    
  }
  
  variable "vpc_enable_nat_gateway" {
      description = "Enable NAT gateway for VPC"
      default = true
    
  }
  
  variable "vpc_single_nat_gateway" {
      description = "Enable Single NAT gateway for VPC"
      default = true
    
  }
  
  variable "vpc_one_nat_gateway_per_az" {
      description = "Enable one NAT gateway per az for VPC"
      default = false
    
  }
  
  variable "vpc_enable_dns_hostnames" {
      description = "enable DNS hostnames"
      default = true
    
  }
  
  variable "vpc_tags" {
      description = "Tags to apply to resources created by VPC module"
      type = map(string)
      default = {
        "Terrform" = "True"
      }
    
  }
  
  
  ###
  # define variables for ec2 instance
  ###
  
  #name = var.ec2_instance_name
  
  variable "ec2_instance_name" {
      description = "Name of EC2 instance"
      type = string
      default = "web server for testing"
  
  }
  
  # ami = var.ec2_instance_ami
  variable "ec2_instance_ami" {
      description = "AMI of EC2 instance"
      type = string
      default = "ami-0beaa649c482330f7"
      
  }
  
  # instance_type = var.ec2_instance_instance_type
  variable "ec2_instance_instance_type" {
      description = "Instance type of EC2 instance"
      type = string
      default = "t2.micro"
      
  }
  
  # key_name = var.ec2_instance_key_name
  
  variable "ec2_instance_key_name" {
      description = "Key name of EC2 instance"
      type = string
      default = "felix-key-pair"
      
  }
  
  
  # tags = var.ec2_instance_tags
  variable "ec2_instance_tags" {
      description = "Tags to apply to EC2 instance"
      type = map(string)
      default = {
        "Terrform" = "True"
      }
    
  }
  
  ###
  # define variables for security group
  ###
  
  variable "web_server_sg_ingress_cidr_blocks" {
      description = "List of IPv4 CIDR ranges to use on all ingress rules for web server HTTP"
      type = list(string)
      default =   [
      "36.152.113.203/32", "218.2.208.75/32", "172.31.0.0/16", "18.162.220.99/32",
      "18.162.103.100/32", "18.162.171.88/32", "58.212.197.96/32", "18.162.198.138/32" 
      ]
  }
  
  variable "ssh_sg_ingress_cidr_blocks" {
      description = "List of IPv4 CIDR ranges to use on all ingress rules for ssh"
      type = list(string)
      default =   [
      "36.152.113.203/32", "218.2.208.75/32", "172.31.0.0/16", "18.162.220.99/32",
      "18.162.103.100/32", "18.162.171.88/32", "58.212.197.96/32", "18.162.198.138/32"
      ]
  }
  ```

  

- outputs.tf

  ```tcl
  output "vpc_public_subnets" {
    description = "IDs of the VPC's public subnets"
    value       = module.vpc.public_subnets
  }
  
  output "ec2_instance_public_dns" {
    description = "The public DNS name assigned to the instance."
    value = module.ec2_instance.public_dns
  }
  ```

- install_web_server.sh

  ```shell
  #!/bin/bash
  yum install -y httpd mysql php
  wget https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-100-TECESS/v4.7.10/lab-1-build-a-web-server/scripts/lab-app.zip
  unzip lab-app.zip -d /var/www/html/
  chkconfig httpd on
  service httpd start
  ```

  

## 1.2 Lab-2 Topology

<img src="https://felixyanghui.synology.me:8441/images/2022/12/12/image-20221212112639946.png" alt="image-20221212112639946" style="zoom:50%;" />



### 1.2.1 Create database and interact with web server (web console)

- Create security group for RDS instance
- Create subnet groups for database
- Create RDS database instance
- Configure web instance on web browser to connect to RDS database instance

### 1.2.2 Create database and interact with web server (Terraform - module)

- Add variables for Dymanadb - MYSQL

  - Use "locals" to define parameters for DB

  ```python
  ###
  # define variables for security group
  ###
  
  variable "web_server_sg_ingress_cidr_blocks" {
      description = "List of IPv4 CIDR ranges to use on all ingress rules for web server HTTP"
      type = list(string)
      default =   [
      "36.152.113.203/32", "218.2.208.75/32", "172.31.0.0/16", "18.162.220.99/32",
      "18.162.103.100/32", "18.162.171.88/32", "58.212.197.96/32", "18.162.198.138/32",
      "117.89.135.187/32" 
      ]
  }
  
  variable "ssh_sg_ingress_cidr_blocks" {
      description = "List of IPv4 CIDR ranges to use on all ingress rules for ssh"
      type = list(string)
      default =   [
      "36.152.113.203/32", "218.2.208.75/32", "172.31.0.0/16", "18.162.220.99/32",
      "18.162.103.100/32", "18.162.171.88/32", "58.212.197.96/32", "18.162.198.138/32",
      "117.89.135.187/32"
      ]
  }
  
  ###
  # define variables for db
  ###
  
  variable "db_sg_name" {
      type = string
      default = "lab"
    
  }
  
  locals {
      web_server_sg_name = "web_server"
      ssh_sg_name = "ssh"
      db_identifier = "lab-db"
  
      db_engine            = "mysql"
      db_engine_version    = "8.0.28"
      db_instance_class    = "db.t3.micro"
      db_allocated_storage = 5
  
      db_db_name  = "lab"
      db_username = "lab_admin"
      db_password = "lab-password"
      db_port     = "3306"
      db_sg_ingress_with_source_security_group_id = [ 
          {
              from_port   = 3306
              to_port     = 3306
              protocol    = "tcp"
              description = "mysql"
              source_security_group_id = module.web_server_sg.security_group_id
        },
      ]
      db_major_engine_version = "8.0"
      db_family = "mysql8.0"
      db_create_db_subnet_group = true
      db_multi_az = true
      db_skip_final_snapshot = true
  }
  
  variable "db_identifier" {
      type = string
      default = "lab-db"
  
  }
  
  variable "db_tags" {
      description = "Tags to apply to db"
      type = map(string)
      default = {
        "Terrform" = "True"
      }
  }
  ```

  

- Add DB in main.tf

  ```python
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
    multi_az = local.db_multi_az
    skip_final_snapshot = local.db_skip_final_snapshot
    vpc_security_group_ids = [module.db_sg.security_group_id]
    tags = var.db_tags
    # DB subnet group
    create_db_subnet_group = local.db_create_db_subnet_group
    subnet_ids = module.vpc.private_subnets
    
  }
  ```

  

- output.tf

  ```python
  output "db_db_instance_endpoint" {
    description = "The connection endpoint"
    value = module.db.db_instance_endpoint
    
  }
  ```

  

## 1.3 Lab-3 Topology

<img src="https://felixyanghui.synology.me:8441/images/2022/12/02/image-20221129160103938.png" style="zoom:50%;" />

### 1.3.1 Autoscalaing, Loadbalancer and Cloud Watch

- Create AMI from running EC2 - web server

- Create loadbalancer:  ALB

  ![image-20221212135325032](https://felixyanghui.synology.me:8441/images/2022/12/12/image-20221212135325032.png)

- Create EC2 launch template

- Create auto-scalling group, enable load balancer and choose the target group which configured in ALB creation step

  ![image-20221212141947725](https://felixyanghui.synology.me:8441/images/2022/12/12/image-20221212141947725.png)

- Validate load balancer if run probably, by accessing the load balancer DNS name. Refresh browser will show different EC2 name as load balancer load balance the traffic to different EC2 in target group

- Create ASG policy "Target tracking scalling policy", which automatically create CloudWatch alarm to monitor the CPU utilization of ASG

### 1.3.2 Autoscalaing, Loadbalancer and Cloud Watch (Terraform - Module)

- Add ALB, ASG and related security groups in main.tf

  ```tcl
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
    egress_with_cidr_blocks = local.asg_sg_egress_with_cidr_blocks
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
  
    image_id          = local.asg_image_id
    instance_type     = local.asg_instance_type
    key_name          = var.ec2_instance_key_name
    
  	# use pre-defined sg, only allow the access from loadbalancers or others in sg: web server group
    security_groups = [module.asg_sg.security_group_id]
  
    # create autoscaling policy based on avgCPUutilization
    scaling_policies = local.asg_scaling_policies
  
  
    tags = local.asg_tags
  }
  ```

- Define related variables and locals in variables.tf

  ```tcl
  locals {
      ...
  
      # alb
      alb_load_balancer_type = "application"
      alb_name = "lab-alb"
      alb_target_groups = [
          {
          name_prefix      = "pref-"
          backend_protocol = "HTTP"
          backend_port     = 80
          }
      ]
  
      alb_http_tcp_listeners = [
          {
              port               = 80
              protocol           = "HTTP"
              target_group_index = 0
          }
      ]
  
      alb_tags = {
  
          "Terrform" = "True"
      }
  
      #asg
      asg_sg_ingress_with_source_security_group_id = [ 
          {
              from_port   = 80
              to_port     = 80
              protocol    = "tcp"
              description = "web"
              source_security_group_id = module.web_server_sg.security_group_id
        },
          {
              from_port   = 22
              to_port     = 22
              protocol    = "tcp"
              description = "ssh"
              source_security_group_id = module.web_server_sg.security_group_id
        },
      ]
  		
  		# define egress policy to allow all protocols for EC2 in private subnet to access internet
      asg_sg_egress_with_cidr_blocks = [
          {
              from_port = -1
              to_port = -1
              # value = "all" to allow all protocols
              protocol    = "all"
              description = "all ports for egress of EC2"
              cidr_blocks = "0.0.0.0/0"
          },
      ]
  
      asg_name = "lab-asg"
      asg_min_size                  = 2
      asg_max_size                  = 4
      asg_desired_capacity          = 2
      asg_wait_for_capacity_timeout = 0
      asg_health_check_type         = "EC2"
      asg_instance_refresh = {
          strategy = "Rolling"
          preferences = {
              checkpoint_delay       = 600
              checkpoint_percentages = [35, 70, 100]
              instance_warmup        = 300
              min_healthy_percentage = 50
          }
          triggers = ["tag"]
      }
  
  
      asg_lc_name           = "lab-asg-launch-configuration"
      asg_image_id          = "ami-0366e7e36827b904b"
      asg_instance_type     = "t2.micro"
      asg_ebs_optimized     = true
      asg_enable_monitoring = true
  
  
      asg_tags = {
          "Terrform" = "True"
      }
  
      asg_sg_name = "lab-asg-sg"
  
      asg_scaling_policies = {
          lab-autoscaling-policy = {
              policy_type               = "TargetTrackingScaling"
              target_tracking_configuration = {
                  predefined_metric_specification = {
                  predefined_metric_type = "ASGAverageCPUUtilization"
                  # resource_label         = "Lab-Label"
                  }
                  target_value = 50.0
              }
          }
      }
  
  }
  ```

  