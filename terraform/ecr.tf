# ===================== ECR Repository for Application Container Images =====================

resource "aws_ecr_repository" "app" {
  name = "${var.app_name}-${local.environment}-ecr-repository"
  force_delete = true  # Allow non-empty repository deletion
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = <<EOF
    {
        "rules": [
            {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
            }
        ]
    }
    EOF
}

# ===================== ECR Repository for Application Container Images =====================
