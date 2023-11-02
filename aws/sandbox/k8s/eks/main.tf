module "eks_tags" {
  source = "../../global/tags"
  
  name = "terraform-playground-eks"
}

data "aws_iam_role" "eks_iam_role" {
  name = "AWSServiceRoleForAmazonEKS"
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

resource "aws_eks_node_group" "eks_nodegroup" {
  count           = length(var.nodegroup_data)
  cluster_name    = var.cluster_name
  node_group_name = var.nodegroup_data[count.index].name
  node_role_arn   = data.aws_iam_role.eks_iam_role.arn
  subnet_ids      = var.nodegroup_subnet[count.index]


  dynamic "scaling_config" {
    for_each = try([nodegroup_data.value.scaling_config], null)

    content {
      desired_size = try(scaling_config.value.desired, 1)
      max_size     = try(scaling_config.value.max, 2)
      min_size     = try(scaling_config.value.min, 1)
    }
  }

  update_config {
    max_unavailable = 1
  }
  
  tags = merge(
        module.eks_tags.tags,
        {
          Name = "${each.value.name}"
        }
      )
  
  depends_on = [aws_eks_cluster.eks]
}