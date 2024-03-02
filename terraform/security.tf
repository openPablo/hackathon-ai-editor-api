resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}_allow_loadbalancer-${var.environment}"
  description = "Allow https inbound traffic from loadbalancer"
  vpc_id      = data.aws_vpc.current_environment.id
  ingress {
    protocol         = "TCP"
    to_port         = var.containerPort
    from_port       = var.containerPort
    security_groups = [
      data.aws_security_group.prometheus.id,
      data.aws_security_group.loadbalancer.id
      ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
data aws_security_group loadbalancer {
  name = var.lbSGName
}
data aws_security_group prometheus {
  name = var.promSGName
}

