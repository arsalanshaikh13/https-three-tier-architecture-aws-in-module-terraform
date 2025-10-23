
data "aws_route53_zone" "public-zone" {
  name         = var.hosted_zone_name
  private_zone = false
}
resource "aws_route53_record" "cloudfront_record" {
  zone_id = data.aws_route53_zone.public-zone.zone_id
  # name    = "week3.${data.aws_route53_zone.public-zone.name}"
  name    = "${data.aws_route53_zone.public-zone.name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
# trying to create an A record for aliases of domain name used in cloudfront 
resource "aws_route53_record" "cloudfront" {
  # for_each = aws_cloudfront_distribution.s3_distribution.aliases
  for_each = toset(var.cloudfront_distro_aliases)
  zone_id  = data.aws_route53_zone.public-zone.zone_id
  name     = each.value
  type     = "A"

  alias {
    # name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    # zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# AWS certificate Manager performing dns validation and creating certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = var.hosted_zone_name
  subject_alternative_names = ["www.${var.hosted_zone_name}"]
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create dns record in route53 for certificate
# data "aws_route53_zone" "selected_zone" {
#   name         = var.hosted_zone_name
#   private_zone = false
# }

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  # zone_id         = data.aws_route53_zone.selected_zone.zone_id
  zone_id         = data.aws_route53_zone.public-zone.zone_id
}


resource "aws_acm_certificate_validation" "cert_validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}