
data "aws_route53_zone" "public-zone" {
  name         = var.certificate_domain_name
  # name         = var.hosted_zone_name
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

