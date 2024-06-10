resource "aws_acm_certificate" "example" { # This will create certificate
  domain_name       = "*.dawsmani.site"
  validation_method = "DNS"
 
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}"
    }
  )
}
# Below is for Validation method code
resource "aws_route53_record" "expense" { # This updates the records in our Domain
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 1 # Time to Live --> 1 -To immediately record
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "expense" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [for record in aws_route53_record.expense : record.fqdn]
}
