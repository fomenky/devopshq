provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name]
      command     = "aws"
    }
  }
  # registry {
  #   url      = "oci://${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com"
  #   username = data.aws_ecr_authorization_token.token.user_name
  #   password = data.aws_ecr_authorization_token.token.password
  # }
}

module "eks_tags" {
  source = "../../global/tags"
  
  name = "terraform-playground-eks"
}

## ECR Module ##
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "helloworld-chart"
  repository_type = "private"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 3 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 3
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = merge(
      module.eks_tags.tags,
      {
        Name = "sandbox-ecr"
      }
    )
}
data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {
  registry_id = data.aws_caller_identity.current.account_id
  depends_on = [module.ecr]
}

data "aws_subnet" "public-subnet-a" {
  filter {
    name   = "tag:Name"
    values = ["sbn-ibs-d-ue1-public-a"]
  }
}

data "aws_subnet" "public-subnet-b" {
  filter {
    name   = "tag:Name"
    values = ["sbn-ibs-d-ue1-public-b"]
  }
}

data "aws_iam_role" "eks_iam_role" {
  name = "role-sandbox-ec2-service-role"
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
    # endpoint_private_access = true
    endpoint_public_access  = true  # Temporary: Set to true for testing purpose
    # subnet_ids = var.subnets
    subnet_ids = [data.aws_subnet.public-subnet-a.id, data.aws_subnet.public-subnet-b.id]
  }
  
  tags = merge(
        module.eks_tags.tags,
        {
          Name = "${var.cluster_name}"
        }
      )
}

resource "aws_eks_node_group" "this" {
  # count           = length(var.subnets)
  
  cluster_name    = var.cluster_name
  # node_group_name = "nodegroup-${count.index}"
  node_group_name = "nodegroup-1"
  node_role_arn   = data.aws_iam_role.eks_iam_role_ng.arn
  # subnet_ids      = ["${tolist(var.subnets)[count.index]}"]
  subnet_ids      = [data.aws_subnet.public-subnet-a.id]

  instance_types  = ["t3.small"]
  
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

## Helm Packages ##
resource "helm_release" "helloworld" {
  name       = "helloworld-chart"
  repository = "oci://${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com"
  chart      = "helloworld-chart"
  version    = "0.1.0"

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "image.tag"
    value = "0.0.1"
  }
}
