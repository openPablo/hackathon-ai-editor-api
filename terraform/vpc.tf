data "aws_vpc" "current_environment" {
  filter {
    name = "tag:Stage"
    values = [var.vpcEnvironment]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.current_environment.id]
  }

  filter {
    name = "tag:Name"
    values = ["private-subnet-*"]
  }
}
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.current_environment.id]
  }

  filter {
    name = "tag:Name"
    values = ["public-subnet-*"]
  }
}
