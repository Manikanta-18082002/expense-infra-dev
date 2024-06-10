data "aws_cloudfront_cache_policy" "cache_enable" {
  name = "Managed-CachingOptimized" # This Name is from --> CloudFront --> Policies --> Cache
}

data "aws_cloudfront_cache_policy" "cache_disable" {
  name = "Managed-CachingDisabled" # Same from above
}

data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/${var.project_name}/${var.environment}/acm_certificate_arn"
}