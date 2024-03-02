provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Application = var.project
      Stage = var.environment
    }
  }
}
data "aws_caller_identity" "current" {}
terraform {
  required_version = "> 1.5"
  backend "s3" {
    encrypt        = true
    bucket         = "hollywood-terraform-states"
    region         = "eu-west-1"
    key            = "vc-pilot-backend/prod/terraform.tfstate"
  }
}