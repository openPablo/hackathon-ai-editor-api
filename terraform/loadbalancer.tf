data "aws_lb" "alb" {
    name = var.lbName
}

data aws_lb_listener https {
    load_balancer_arn = data.aws_lb.alb.arn
    port              = 443
}

resource "aws_lb_listener_rule" "rule" {
    listener_arn = data.aws_lb_listener.https.arn
    priority     = 69
    action {
        target_group_arn = aws_lb_target_group.target.arn
        type             = "forward"
    }
    condition {
        host_header {
            values = [
                aws_route53_record.record.fqdn
            ]
        }
    }
}

resource "aws_lb_target_group" "target" {
    deregistration_delay          = "20"
    load_balancing_algorithm_type = "round_robin"
    port                          = var.containerPort
    protocol                      = "HTTP"
    protocol_version              = "HTTP1"
    slow_start                    = 0
    target_type                   = "ip"
    vpc_id                        = data.aws_vpc.current_environment.id
    lifecycle {
    create_before_destroy = true
    }

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 10
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        unhealthy_threshold = 5
    }
    stickiness {
        cookie_duration = 86400
        enabled         = false
        type            = "lb_cookie"
    }
}