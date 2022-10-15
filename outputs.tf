output "cloudfront" {
  value       = { for key, value in aws_cloudfront_distribution.distribution : key => value }
  description = "Collection of outputs for the created CloudFront distribution."
}

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.id, [""]), 0)
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.arn, [""]), 0)
}

output "cloudfront_distribution_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.caller_reference, [""]), 0)
}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.status, [""]), 0)
}

output "cloudfront_distribution_trusted_signers" {
  description = "List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs"
  value       = element(concat(aws_cloudfront_distribution.distribution.*.trusted_signers, [""]), 0)
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.domain_name, [""]), 0)
}

output "cloudfront_distribution_etag" {
  description = "The current version of the distribution's information."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.etag, [""]), 0)
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to."
  value       = element(concat(aws_cloudfront_distribution.distribution.*.hosted_zone_id, [""]), 0)
}
