# Route53 Hosted Zone

data "aws_route53_zone" "memos_hosted_zone" {
  name = "memos.abuniyyah.uk"
}

# - ACM certificate

resource "aws_acm_certificate" "memos_cert" {
  domain_name       = "memos.abuniyyah.uk"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "memos_cert_valid_record" {
  zone_id = data.aws_route53_zone.memos_hosted_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = "60"
  records = [each.value.record]

  for_each = {
    for dvo in aws_acm_certificate.memos_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}

resource "aws_acm_certificate_validation" "memos_cert_valid" {
  certificate_arn         = aws_acm_certificate.memos_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.memos_cert_valid_record : record.fqdn] # fully-qualified domain name
}

# ALB Alias Record

resource "aws_route53_record" "memos_alb_alias" {
  zone_id = data.aws_route53_zone.memos_hosted_zone.zone_id
  name    = "memos.abuniyyah.uk"
  type    = "A"

  alias {
    name                   = var.memos_alb_dns_name
    zone_id                = var.memos_alb_zone_id
    evaluate_target_health = true
  }
}