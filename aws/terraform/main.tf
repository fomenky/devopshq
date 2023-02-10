#############################################
# PROVIDER && BACKEND
#############################################

## Specifies the RegionS3, Bucket and DynamoDB table to be used for durable backend and state locking
terraform {
  required_version = "~> 0.12"

  required_providers {
    aws = "~> 2.41"
  }

  # dev/staging config
  backend "s3" {
    encrypt = true
    bucket =  "terraform-states-s3-bucket"
    dynamodb_table =  "ddb-terraform-states"
    key = "devops/terraform.tfstate"
    region = "us-west-2"
  }
}

# module "vpc" {
#   source = "./network/vpc"

#   # variables
#   vpc_cidr_block = var.vpc_cidr_block
#   public_subnet_cidr_block = var.public_subnet_cidr_block
#   private_subnet_cidr_block = var.private_subnet_cidr_block

# }
