resource "aws_ecr_repository" "ecs-repo" {
  count = var.environment == "prod" ? 1 : 0
  name                 = var.project
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_lifecycle_policy" "remove-after-30" {
  count = var.environment == "prod" ? 1 : 0
  repository = aws_ecr_repository.ecs-repo[0].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}