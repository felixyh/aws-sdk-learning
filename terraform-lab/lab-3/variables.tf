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

    # alb
    alb_load_balancer_type = "application"
    alb_name = "lab-alb"
    alb_target_groups = [
        {
        name_prefix      = "pref-"
        backend_protocol = "HTTP"
        backend_port     = 80
        # target_type      = "instance"
        # targets = {
        #     my_target = {
        #         target_id = "i-0123456789abcdefg"
        #         port = 80
        #         }
        #     my_other_target = {
        #         target_id = "i-a1b2c3d4e5f6g7h8i"
        #         port = 8080
        #         }
        #     }
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

    asg_sg_egress_with_cidr_blocks = [
        {
            from_port = -1
            to_port = -1
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

