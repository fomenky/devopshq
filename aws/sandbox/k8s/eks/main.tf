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
}

# resource "helm_release" "nginx" {
#   name       = "nginx"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx"

#   values = [
#     file("${path.module}/nginx-values.yaml")
#   ]
# }

module "eks_tags" {
  source = "../../global/tags"
  
  name = "terraform-playground-eks"
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


resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "cluster_role_binding_test"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}