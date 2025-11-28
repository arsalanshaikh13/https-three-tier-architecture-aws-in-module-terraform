
variable "certificate_domain_name" {
  type        = string
  # default = "devsandbox.space"
  description = "certificate_domain_name variable"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "cloudfront_domain_name variable"
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "cloudfront_hosted_zone_id variable"
}

variable "cloudfront_distro_aliases" {
  type        = list(string)
  description = "cloudfront_distro_aliases variable"
}

