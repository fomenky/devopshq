module "eks_tags" {
  source = "../../global/tags"
  
  name = "terraform-playground-eks"
}

data "aws_iam_role" "eks_iam_role" {
  name = "AWSServiceRoleForAmazonEKS"
}

data "aws_iam_role" "eks_iam_role_ng" {
  name = "role-sandbox-ec2-service-role"
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

resource "aws_eks_cluster" "this" {
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


resource "aws_eks_node_group" "this" {
  count           = length(var.subnets)
  
  cluster_name    = var.cluster_name
  node_group_name = "nodegroup-${count.index}"
  node_role_arn   = data.aws_iam_role.eks_iam_role_ng.arn
  subnet_ids      = ["${tolist(var.subnets)[count.index]}"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  
  tags = merge(
        module.eks_tags.tags,
        {
          Name = "${var.cluster_name}"
        }
      )
  
  depends_on = [aws_eks_cluster.this]
}