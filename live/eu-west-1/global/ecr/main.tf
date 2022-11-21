module "ecr_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  namespace   = var.project_name
  environment = var.environment
  name        = "ecr"

  delimiter = "-"

  tags = merge(
    {
      "Component" = "ecr"
    },
    var.default_tags
  )
}


module "ecr_stark" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "stark"

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_image_tag_mutability = "MUTABLE"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 5 images for dev branch.",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["dev"],
          countType     = "imageCountMoreThan",
          countNumber   = 5
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "Keep last 5 images for master branch.",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["master"],
          countType     = "imageCountMoreThan",
          countNumber   = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  tags = module.ecr_label.tags
}


################################################################################
# Data Sources
################################################################################


data "aws_caller_identity" "current" {}