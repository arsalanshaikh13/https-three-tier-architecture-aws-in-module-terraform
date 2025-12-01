# Output the certificate ARN
output "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  value       = aws_acm_certificate.cert.arn
}

# Output the domain name
output "acm_certificate_domain_name" {
  description = "ACM Certificate Domain Name"
  value       = aws_acm_certificate.cert.domain_name
}

# Output the certificate status
output "acm_certificate_status" {
  description = "ACM Certificate Status"
  value       = aws_acm_certificate.cert.status
}

# Output the name servers for updating domain registrar
output "name_servers" {
  description = "Name servers to configure at domain registrar"
  value       = aws_route53_zone.devsandbox.name_servers
}

# Output the hosted zone ID
output "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = aws_route53_zone.devsandbox.zone_id
}
output "route53_zone_name" {
  description = "Route53 Hosted Zone name"
  value       = aws_route53_zone.devsandbox.name
}

# Output the hosted zone ARN
output "route53_zone_arn" {
  description = "Route53 Hosted Zone ARN"
  value       = aws_route53_zone.devsandbox.arn
}
