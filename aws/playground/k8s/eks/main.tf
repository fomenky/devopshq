module "eks_tags" {
  source = "../../global/tags"
  
  name = "terraform-playground-eks"
}

data "aws_iam_role" "eks_iam_role" {
  name = "AWSServiceRoleForAmazonEKS"
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.eks_iam_role.arn

  vpc_config {
    subnet_ids = var.subnets
  }
  
  tags = merge(
        module.eks_tags.tags,
        {
          Name = "${var.cluster_name}"
        }
      )
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}