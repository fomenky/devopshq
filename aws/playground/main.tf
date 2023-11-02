locals {
  cluster_name = "terraform-playground-eks-${random_string.suffix.result}"
}

module "network" {
  source = "./infra/network"

  # input variables
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block

}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
source  = "./k8s/eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"
  
  subnets  = [module.network.public_subnet_one, module.network.private_subnet_one]
}