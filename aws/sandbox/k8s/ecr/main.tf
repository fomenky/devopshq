module "eks_tags" {
  source = "../../global/tags"
  
  name = "terraform-ecr"
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = var.repository_force_delete

  tags = merge(
      module.eks_tags.tags,
      {
        Name = "sandbox-ecr"
      }
    )
}