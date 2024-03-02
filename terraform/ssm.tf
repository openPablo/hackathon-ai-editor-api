resource "aws_ssm_parameter" "commit-tag" {
  type = "String"
  name = "/${var.project}/${var.environment}"
  value = "empty"
  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "commit-tag" {
  depends_on = [
    aws_ssm_parameter.commit-tag
  ]
  name = "/${var.project}/${var.environment}"
}

data "aws_ssm_parameter" "loki_url" {
  name = "/videobs/LOKI_URL"
}

data "aws_ssm_parameter" "tempo_url" {
  name = "/videobs/TEMPO_URL"
}
