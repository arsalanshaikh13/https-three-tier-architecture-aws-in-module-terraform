# AWS certificate Manager performing dns validation and creating certificate
resource "aws_acm_certificate" "cert" {
  domain_name = var.certificate_domain_name
  # subject_alternative_names = ["www.${var.certificate_domain_name}", "api.${var.certificate_domain_name}"]
  subject_alternative_names = [var.additional_domain_name]
  # subject_alternative_names = [var.additional_domain_name, var.alb_api_domain_name]
  # validation_method = "DNS"
  validation_method = var.acm_validation_method

  tags = {
    Name        = "Acm-certificate-for-domain"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# since certificate is being created using dns validation method, we need to create route53 records for validation
resource "aws_route53_zone" "devsandbox" {
  # name    = "devsandbox.space"
  name    = var.certificate_domain_name
  comment = "Hosted zone for ${var.certificate_domain_name} domain"

  tags = {
    Name        = "${var.certificate_domain_name}-domain-name"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}



# create dns record in route53 for certificate
# data "aws_route53_zone" "public-zone" {
#   name         = var.certificate_domain_name
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
  # zone_id         = data.aws_route53_zone.public-zone.zone_id
  zone_id         = aws_route53_zone.devsandbox.zone_id
  depends_on = [ aws_route53_zone.devsandbox ]
}


resource "aws_acm_certificate_validation" "cert_validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}