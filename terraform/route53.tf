resource "aws_route53_record" "record" {
    name    = "${var.project}-${var.environment}.${data.aws_route53_zone.zone.name}"
    type    = "A"
    zone_id = data.aws_route53_zone.zone.id
    alias {
        evaluate_target_health = false
        name                   = data.aws_lb.alb.dns_name
        zone_id                = data.aws_lb.alb.zone_id
    }
}
data "aws_route53_zone" "zone" {
  name = var.route53Zone
}