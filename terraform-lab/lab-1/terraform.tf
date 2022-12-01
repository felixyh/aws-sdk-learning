terraform {
    /*This file defines the terraform block, which Terraform uses to configures itself. 
    This block specifies this Terraform configuration must use the aws provider that is 
    within the v4.4.0 minor release. 
    It also requires that you use a Terraform version greater than v1.1.0.
    */

  # cloud {
  #   organization = "organization-name"
  #   workspaces {
  #     name = "learn-terraform-module-use"
  #   }
  # }


  required_providers{
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 4.4.0"
    }
  }
  required_version = ">= 1.1.0"
}
