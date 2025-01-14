# Basic usage

Basic usage example.

Example demonstrates creating a CloudFront distribution with an S3 origin.

Example shows using Default Tags in the provider as well as passing additional tags into the resource.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Examples

```hcl
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.38.0, < 5.1.0"
    }
  }
}

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
  version = "4.1.0"

  name = var.name
  tags = {
    example = "true"
  }
  enable_oai = true
}

output "s3" {
  value = module.s3
}

# Get ID for Cache Policy
data "aws_cloudfront_cache_policy" "cache_policy_id" {
  name = "UseOriginCacheControlHeaders"
}

# Get ID for Origin Policy
data "aws_cloudfront_origin_request_policy" "origin_policy_id" {
  name = "Managed-AllViewer"
}

module "cloudfront" {
  #tfsec:ignore:aws-cloudfront-enable-logging - Logging not enabled for this example.
  #checkov:skip=CKV2_AWS_174:"Verify CloudFront Distribution Viewer Certificate is using TLS v1.2" Module uses 1.2 by default.

  source = "../../"
  # source  = "so1omon563/cloudfront/aws"
  # version = "1.0.0"

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
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = module.s3.oai_module.enabled.oai.comment
    cache_policy_id          = data.aws_cloudfront_cache_policy.cache_policy_id.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.origin_policy_id.id
  }
}

output "cloudfront" { value = module.cloudfront }
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.38.0, < 5.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.0.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../../ | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | so1omon563/s3/aws | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.dummy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [tls_private_key.dummy](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.dummy](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_cloudfront_cache_policy.cache_policy_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.origin_policy_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"example-cf"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map` | <pre>{<br>  "environment": "dev",<br>  "kitchen": "true",<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront"></a> [cloudfront](#output\_cloudfront) | n/a |
| <a name="output_s3"></a> [s3](#output\_s3) | n/a |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
