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