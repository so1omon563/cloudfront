# Basic usage

Basic usage example can be found in the `*.tf` source files.

Example demonstrates creating a CloudFront distribution with an S3 origin.

Example shows using Default Tags in the provider as well as passing additional tags into the resource.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.34.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../.. | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | so1omon563/s3/aws | 1.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.dummy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [tls_private_key.dummy](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.dummy](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

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
