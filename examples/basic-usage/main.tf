variable "name" {
  default = "example-cf"
}

variable "tags" {
  default = {
    environment = "dev"
    terraform   = "true"
    kitchen     = "true"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.tags
  }
}

# Create additional blank variables here that you have values for in auto.default.tfvars

## Create a dummy self-signed certificate
resource "tls_private_key" "dummy" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "dummy" {
  private_key_pem = tls_private_key.dummy.private_key_pem

  subject {
    common_name  = "dummy.com"
    organization = "Fake Dummy Inc."
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "dummy" {
  private_key      = tls_private_key.dummy.private_key_pem
  certificate_body = tls_self_signed_cert.dummy.cert_pem

  tags = {
    example = "true"
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Create S3 bucket with OAI for CloudFront
module "s3" {
  source  = "so1omon563/s3/aws"
  version = "1.2.0"

  name = var.name
  tags = {
    example = "true"
  }
  enable_oai = true
}

output "s3" {
  value = module.s3
}
module "cloudfront" {
  #tfsec:ignore:aws-cloudfront-enable-logging - Logging not enabled for this example.
  #checkov:skip=CKV2_AWS_174:"Verify CloudFront Distribution Viewer Certificate is using TLS v1.2" Module uses 1.2 by default.

  source = "../.." # Verify this path is correct

  name = var.name
  tags = {
    example = "true"
  }
  origin = [{
    domain_name         = module.s3.bucket.bucket_domain_name
    origin_id           = module.s3.oai_module.enabled.oai.comment
    connection_attempts = 3
    connection_timeout  = 10
    origin_path         = null
  }]
  s3_origin_config = [{
    origin_access_identity = module.s3.oai_module.enabled.oai.cloudfront_access_identity_path
  }]
  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.dummy.arn
  }
  default_cache_behavior = {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = module.s3.oai_module.enabled.oai.comment
  }
}

output "cloudfront" { value = module.cloudfront }
