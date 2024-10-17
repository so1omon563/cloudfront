#tfsec:ignore:aws-cloudfront-enable-logging - Since this is a re-usable module, this needs to be able to be overridden.
resource "aws_cloudfront_distribution" "distribution" {
  #checkov:skip=CKV_AWS_174:"Verify CloudFront Distribution Viewer Certificate is using TLS v1.2" Module uses 1.2 by default.
  #checkov:skip=CKV2_AWS_32:"Ensure CloudFront distribution has a response headers policy attached" Re-usable module allows for this to not be provided.

  aliases = var.aliases
  comment = var.comment != null ? var.comment : format("CloudFront distribution for %s", local.distribution_name)

  dynamic "custom_error_response" {
    for_each = local.custom_error_response
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  default_cache_behavior {
    allowed_methods            = local.default_cache_behavior.allowed_methods
    cached_methods             = local.default_cache_behavior.cached_methods
    cache_policy_id            = local.default_cache_behavior.cache_policy_id
    compress                   = tobool(local.default_cache_behavior.compress)
    default_ttl                = tonumber(local.default_cache_behavior.default_ttl)
    field_level_encryption_id  = local.default_cache_behavior.field_level_encryption_id
    min_ttl                    = tonumber(local.default_cache_behavior.min_ttl)
    max_ttl                    = tonumber(local.default_cache_behavior.max_ttl)
    origin_request_policy_id   = local.default_cache_behavior.origin_request_policy_id
    realtime_log_config_arn    = local.default_cache_behavior.realtime_log_config_arn
    response_headers_policy_id = local.default_cache_behavior.response_headers_policy_id
    smooth_streaming           = tobool(local.default_cache_behavior.smooth_streaming)
    target_origin_id           = local.default_cache_behavior.target_origin_id
    trusted_key_groups         = local.default_cache_behavior.trusted_key_groups
    trusted_signers            = local.default_cache_behavior.trusted_signers
    viewer_protocol_policy     = local.default_cache_behavior.viewer_protocol_policy


    dynamic "forwarded_values" {
      for_each = local.forwarded_values_condition
      content {
        cookies {
          forward           = local.forwarded_values_cookies.forward != null ? local.forwarded_values_cookies.forward : null
          whitelisted_names = local.forwarded_values_cookies.whitelisted_names != null ? local.forwarded_values_cookies.whitelisted_names : null
        }
        headers                 = local.forwarded_values.headers != null ? local.forwarded_values.headers : null
        query_string            = local.forwarded_values.query_string != null ? tobool(local.forwarded_values.query_string) : null
        query_string_cache_keys = local.forwarded_values.query_string_cache_keys != null ? local.forwarded_values.query_string_cache_keys : null
      }
    }
  }

  default_root_object = var.default_root_object

  enabled         = var.enabled
  is_ipv6_enabled = var.is_ipv6_enabled

  http_version = var.http_version

  dynamic "logging_config" {
    for_each = local.logging_config
    content {
      bucket          = logging_config.value.bucket
      include_cookies = tobool(logging_config.value.include_cookies)
      prefix          = logging_config.value.prefix
    }
  }

  //  ordered_cache_behavior = NOT CURRENTLY SUPPORTING

  dynamic "origin" {
    for_each = var.origin
    content {
      connection_attempts = tonumber(origin.value.connection_attempts)
      connection_timeout  = tonumber(origin.value.connection_timeout)
      domain_name         = origin.value.domain_name
      origin_id           = origin.value.origin_id
      origin_path         = origin.value.origin_path

      dynamic "custom_header" {
        for_each = local.custom_header
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
      dynamic "custom_origin_config" {
        for_each = local.custom_origin_config
        content {
          http_port                = tonumber(custom_origin_config.value.http_port)
          https_port               = tonumber(custom_origin_config.value.https_port)
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = tonumber(custom_origin_config.value.origin_keepalive_timeout)
          origin_read_timeout      = tonumber(custom_origin_config.value.origin_read_timeout)
        }
      }

      dynamic "origin_shield" {
        for_each = local.origin_shield
        content {
          enabled              = tobool(origin_shield.value.enabled)
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }

      dynamic "s3_origin_config" {
        for_each = local.s3_origin_config
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

    }
  }

  //  origin_group = NOT CURRENTLY SUPPORTING


  price_class = var.price_class

  restrictions {
    geo_restriction {
      locations        = local.restrictions.locations
      restriction_type = local.restrictions.restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn            = local.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = local.viewer_certificate.cloudfront_default_certificate
    iam_certificate_id             = local.viewer_certificate.iam_certificate_id
    minimum_protocol_version       = local.viewer_certificate.minimum_protocol_version
    ssl_support_method             = local.viewer_certificate.ssl_support_method
  }

  web_acl_id = var.web_acl_id

  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  tags = merge({ "Name" = local.distribution_name }, local.tags)
}
