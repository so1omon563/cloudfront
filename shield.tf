resource "aws_shield_protection" "cf" {
  count        = var.shield_advanced_protection ? 1 : 0
  name         = local.distribution_name
  resource_arn = aws_cloudfront_distribution.distribution.arn

  tags = local.tags
}
