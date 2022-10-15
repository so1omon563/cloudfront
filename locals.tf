locals {
  tags = var.tags

  distribution_name = var.distribution_name_override != null ? var.distribution_name_override : var.distribution_prefix == null ? format("%s", var.name) : format("%s-%s", var.name, var.distribution_prefix)

  # for_each locals
  custom_error_response = var.custom_error_response[0].error_code != null ? var.custom_error_response : []
  custom_header         = var.custom_header[0].name != null ? var.custom_header : []
  custom_origin_config  = var.custom_origin_config[0].http_port != null ? var.custom_origin_config : []
  logging_config        = var.logging_config[0].bucket != null ? var.logging_config : []
  origin_shield         = var.origin_shield[0].enabled != null ? var.origin_shield : []
  s3_origin_config      = var.s3_origin_config[0].origin_access_identity != null ? var.s3_origin_config : []

  # defaults locals for merging
  default_cache_behavior_defaults = {
    # (Required) - Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin.
    # Must be a list.
    allowed_methods = ["GET", "HEAD"]

    # (Required) - Controls whether CloudFront caches the response to requests using the specified HTTP methods.
    # Must be a list.
    cached_methods = ["GET", "HEAD"]

    # (Optional) - The unique identifier of the cache policy that is attached to the cache behavior.
    cache_policy_id = null

    # (Optional) - Whether you want CloudFront to automatically compress content for web requests that include **Accept-Encoding: gzip** in the request header (default: **false**).
    compress = false

    # (Optional) - The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an **Cache-Control max-age** or **Expires** header.
    default_ttl = null

    # (Optional) - Field level encryption configuration ID
    field_level_encryption_id = null

    # (Optional) - The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated.
    # Only effective in the presence of **Cache-Control max-age**, **Cache-Control s-maxage**, and **Expires** headers.
    max_ttl = null

    # (Optional) - The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds.
    min_ttl = 0

    # (Optional) - The unique identifier of the origin request policy that is attached to the behavior.
    origin_request_policy_id = null

    # (Optional) - The ARN of the [real-time log configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_realtime_log_config) that is attached to this cache behavior.
    realtime_log_config_arn = null

    # (Optional) - The identifier for a response headers policy.
    response_headers_policy_id = null

    # (Optional) - Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior.
    smooth_streaming = false

    # (Required) - The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior.
    target_origin_id = null

    # (Optional) - A list of key group IDs that CloudFront can use to validate signed URLs or signed cookies. See the [CloudFront User Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html) for more information about this feature.
    # Must be a list.
    trusted_key_groups = null

    # (Optional) - List of AWS account IDs (or **self**) that you want to allow to create signed URLs for private content. See the [CloudFront User Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html) for more information about this feature.
    # Must be a list.
    trusted_signers = null

    # (Required) - Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern.
    # One of **allow-all**, **https-only**, or **redirect-to-https**.
    viewer_protocol_policy = "redirect-to-https"
  }
  default_cache_behavior = merge(local.default_cache_behavior_defaults, var.default_cache_behavior)

  forwarded_values_defaults = {
    # (Optional) - Specifies the Headers, if any, that you want CloudFront to vary upon for this cache behavior. Specify * to include all headers.
    headers = null
    # (Required) - Boolean that indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior.
    query_string = true
    # (Optional) - When specified, along with a value of **true** for **query_string**, all query strings are forwarded, however only the query string keys listed in this argument are cached.
    # When omitted with a value of **true** for **query_string**, all query string keys are cached.
    # Must be a list.
    query_string_cache_keys = null
  }
  forwarded_values = merge(local.forwarded_values_defaults, var.forwarded_values)

  forwarded_values_cookies_defaults = {
    # (Required) - Specifies whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior.
    # You can specify **all**, **none** or **whitelist**. If **whitelist**, you must include the subsequent **whitelisted_names**.
    forward = "none"

    # (Optional) - If you have specified **whitelist** to **forward**, the whitelisted cookies that you want CloudFront to forward to your origin.
    whitelisted_names = null
  }
  forwarded_values_cookies = merge(local.forwarded_values_cookies_defaults, var.forwarded_values_cookies)

  restrictions_defaults = {
    # The **restrictions** sub-resource only takes another single sub-resource named **geo_restriction**.
    # These values are technically for that additional sub-resource.

    # (Optional) - The [ISO 3166-1-alpha-2 codes](https://www.iso.org/iso-3166-country-codes.html) for which you want CloudFront either to distribute your content (**whitelist**) or not distribute your content (**blacklist**).
    # Not needed if the **restriction_type** is set to **none**.
    # Must be a list.
    locations = null

    # (Required) - The method that you want to use to restrict distribution of your content by country: **none**, **whitelist**, or **blacklist**.
    restriction_type = "none"
  }
  restrictions = merge(local.restrictions_defaults, var.restrictions)

  viewer_certificate_defaults = {
    # The ARN of the [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) certificate that you wish to use with this distribution.
    # Specify this, **cloudfront_default_certificate**, or **iam_certificate_id**. The ACM certificate must be in US-EAST-1.
    acm_certificate_arn = null

    # If you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution.
    # Specify this, **acm_certificate_arn**, or **iam_certificate_id**.
    cloudfront_default_certificate = false

    # The IAM certificate identifier of the custom viewer certificate for this distribution if you are using a custom domain.
    # Specify this, **acm_certificate_arn**, or **cloudfront_default_certificate**.
    iam_certificate_id = null

    # The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections.
    # Can only be set if **cloudfront_default_certificate = false**. See all possible values in [this](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html) table under "Security policy."
    # See the [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#minimum_protocol_version) for more detailed information.
    minimum_protocol_version = "TLSv1.2_2021"

    # Specifies how you want CloudFront to serve HTTPS requests. One of **vip** or **sni-only**. Required if you specify **acm_certificate_arn** or **iam_certificate_id**.
    # NOTE: **vip** causes CloudFront to use a dedicated IP address and may incur extra charges.
    ssl_support_method = "sni-only"
  }
  viewer_certificate = merge(local.viewer_certificate_defaults, var.viewer_certificate)

}
