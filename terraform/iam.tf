resource "aws_iam_role" "execution-role" {
  name                = "${var.project}-execution-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.execution-policy.arn]
}

resource "aws_iam_policy" "execution-policy" {
  name = "${var.project}-execution-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
            "ecs:*",
            "logs:*",
            "sns:*",
            "sqs:*",
            "elasticache:*",
            "ecr:*",
            "s3:*",
            "secretsmanager:*",
            "kms:*"
            ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
