variable "name" {
  type        = string
  description = "Short, descriptive name of the environment. All resources will be named using this value as a prefix."
}

variable "distribution_prefix" {
  description = "CloudFront Distribution name prefix, will be appended to `var.name` if a value is supplied."
  type        = string
  default     = null
}

variable "distribution_name_override" {
  description = "Used if there is a need to specify a Distribution name outside of the standardized nomenclature. For example, if importing a distribution that doesn't follow the standard naming formats."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A map of tag names and values for tags to apply to all taggable resources created by the module. Default value is a blank map to allow for using Default Tags in the provider."
  default     = {}
}

variable "aliases" {
  type        = list(string)
  description = "List of extra CNAMEs (alternate domain names), if any, for this distribution."
  default     = null
}

variable "comment" {
  type        = string
  description = "Any comments you want to include about the distribution."
  default     = null
}

variable "custom_error_response" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = string
    response_code         = string
    response_page_path    = string
  }))
  description = <<EOT
  (Optional) - One or more custom [error response elements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#custom-error-response-arguments) (multiples allowed).
  NOTE - All values must be provided, even if that value is `null`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#custom-error-response-arguments) carefully.
  Default values for the options are:
```
  default = [{
    # (Optional) - The minimum amount of time in seconds you want HTTP error codes to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated.
    error_caching_min_ttl = null

    # (Required) - The 4xx or 5xx HTTP status code that you want to customize.
    error_code = null

    # (Optional) - The HTTP status code that you want CloudFront to return with the custom error page to the viewer.
    response_code = null

    # (Optional) - The path of the custom error page (for example, **/custom_404.html**).
    response_page_path = null
  }]
```
  EOT
  default = [{
    error_caching_min_ttl = null
    error_code            = null
    response_code         = null
    response_page_path    = null
  }]
}

variable "custom_header" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(Optional) - One or more sub-resources with `name` and `value` parameters that specify header data that will be sent to the origin (multiples allowed)."
  default = [{
    name  = null
    value = null
  }]
}

variable "custom_origin_config" {
  type = list(object({
    http_port                = number
    https_port               = number
    origin_protocol_policy   = string
    origin_ssl_protocols     = list(string)
    origin_keepalive_timeout = number
    origin_read_timeout      = number
  }))
  description = <<EOT
  One of either this, or `var.s3_origin_config` is REQUIRED.
  NOTE - All values must be provided, even if that value is `null`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#custom-origin-config-arguments) carefully.
  Default values for the options are:
```
  default = [{
    # (Required) - The HTTP port the custom origin listens on.
    http_port = "REQUIRED_VALUE_CHANGE_ME"

    # (Required) - The HTTPS port the custom origin listens on.
    https_port = "REQUIRED_VALUE_CHANGE_ME"

    # (Required) - The origin protocol policy to apply to your origin. One of **http-only**, **https-only**, or **match-viewer**.
    origin_protocol_policy = "match-viewer"

    # (Required) - The SSL/TLS protocols that you want CloudFront to use when communicating with your origin over HTTPS.
    # A list of one or more of **SSLv3**, **TLSv1**, **TLSv1.1**, and **TLSv1.2**.
    origin_ssl_protocols = ["TLSv1.2"]

    # (Optional) The Custom KeepAlive timeout, in seconds.
    # By default, AWS enforces a limit of **60**. But you can request an [increase](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorCustomOrigin.html#request-custom-request-timeout) if needed.
    origin_keepalive_timeout = null

    # (Optional) The Custom Read timeout, in seconds.
    # By default, AWS enforces a limit of **60**. But you can request an [increase](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorCustomOrigin.html#request-custom-request-timeout) if needed.
    origin_read_timeout = null
  }]
```
  EOT
  default = [{
    http_port                = null
    https_port               = null
    origin_protocol_policy   = "match-viewer"
    origin_ssl_protocols     = ["TLSv1.2"]
    origin_keepalive_timeout = null
    origin_read_timeout      = null
  }]
}

variable "default_cache_behavior" {
  //  type        = map(string)
  type = any
  # Setting type to `any` is not ideal. But in order to do a merge on values that require different types, this is the workaround.
  # If we used an object, we wouldn't be able to merge, which means every value would have to always be supplied. For smaller, optional option sets, this is acceptable. But not here.
  description = <<EOT
  REQUIRED variable.

  Note that this variable overrides the values in `local.default_cache_behavior_defaults`

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#cache-behavior-arguments) carefully.
  NOTE - Options for `forwarded_values`, `lambda_function_association`, and `function_association` are captured in their own separate variables.
  Default values for the options are:
```
  local.default_cache_behavior_defaults = {
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
```
  EOT
}

variable "default_root_object" {
  type        = string
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  default     = null
}

variable "enabled" {
  type        = bool
  description = "Whether the distribution is enabled to accept end user requests for content."
  default     = true
}

variable "forwarded_values" {
  type        = any
  description = <<EOT
  (Optional if accepting the `query_string` default) - The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers (maximum one).

  Note that this variable overrides the values in `local.forwarded_values_defaults`.
  Configuration for the `cookies` option is under a separate variable - `var.forwarded_values_cookies`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#forwarded-values-arguments) carefully.
  Default values for the options are:
```
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
```
  EOT
  default     = null
}
variable "forwarded_values_cookies" {
  type        = map(string)
  description = <<EOT
  (Optional if accepting the default `forward` value) - The [forwarded values cookies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#cookies-arguments) that specifies how CloudFront handles cookies (maximum one).

  Note that this variable overrides the values in `local.forwarded_values_cookies_defaults`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#cookies-arguments) carefully.
  Default values for the options are:
```
  forwarded_values_cookies_defaults = {
    # (Required) - Specifies whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior.
    # You can specify **all**, **none** or **whitelist**. If **whitelist**, you must include the subsequent **whitelisted_names**.
    forward = "none"

    # (Optional) - If you have specified **whitelist** to **forward**, the whitelisted cookies that you want CloudFront to forward to your origin.
    whitelisted_names = null
  }
```
  EOT
  default     = null
}

variable "http_version" {
  type        = string
  description = "The maximum HTTP version to support on the distribution. Allowed values are `http1.1` and `http2`."
  validation {
    condition = contains([
      "http1.1",
      "http2"
    ], var.http_version)
    error_message = "Valid values are limited to (http1.1, http2)."
  }
  default = "http2"
}

variable "is_ipv6_enabled" {
  type        = bool
  description = "Whether the IPv6 is enabled for the distribution."
  default     = false
}

variable "logging_config" {
  type = list(object({
    bucket          = string
    include_cookies = bool
    prefix          = string
  }))
  description = <<EOT
  (Optional) - The [logging configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#logging-config-arguments) that controls how logs are written to your distribution (maximum one).
  NOTE - If using this varialbe, ALL values must be provided, even if that value is `null`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#logging-config-arguments) carefully.
  Default values for the options are:
```
  default = [{
    # (Required if using logging_config) - The Amazon S3 bucket to store the access logs in, for example, **myawslogbucket.s3.amazonaws.com**.
    bucket = null

    # (Optional) - Specifies whether you want CloudFront to include cookies in access logs (default: **false**).
    include_cookies = false

    # (Optional) - An optional string that you want CloudFront to prefix to the access log filenames for this distribution, for example, **myprefix/**.
    prefix = null
  }]
```
  EOT
  default = [{
    bucket          = null
    include_cookies = false
    prefix          = null
  }]
}
variable "origin" {
  type = list(object({
    connection_attempts = number
    connection_timeout  = number
    domain_name         = string
    origin_id           = string
    origin_path         = string
  }))
  description = <<EOT
  REQUIRED variable. Even though there are defaults, this variable must be passed in.
  NOTE - All values must be provided, even if that value is `null`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#origin-arguments) carefully.
  NOTE - Options for `custom_headers`, `custom_origin_config`, `origin_shield`, and `s3_origin_config` are captured in their own separate variables.
  Either `var.custom_origin_config` or `var.s3_origin_config` are also REQUIRED.
  Default values for the options are:
```
  default = [{
    # (Optional) - The number of times that CloudFront attempts to connect to the origin.
    # Must be between 1-3. Defaults to 3.
    connection_attempts = 3

    # (Optional) - The number of seconds that CloudFront waits when trying to establish a connection to the origin.
    # Must be between 1-10. Defaults to 10.
    connection_timeout = 10

    # (Required) - The DNS domain name of either the S3 bucket, or web site of your custom origin.
    domain_name = "REQUIRED_VALUE_CHANGE_ME"

    # (Required) - A unique identifier for the origin.
    origin_id = "REQUIRED_VALUE_CHANGE_ME"

    # (Optional) - An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin.
    origin_path = null
 }]
```
  EOT
  default = [{
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = "REQUIRED_VALUE_CHANGE_ME"
    origin_id           = "REQUIRED_VALUE_CHANGE_ME"
    origin_path         = null
  }]
}

variable "price_class" {
  type        = string
  description = "The price class for this distribution. One of `PriceClass_All`, `PriceClass_200`, `PriceClass_100`."
  validation {
    condition = var.price_class == null ? true : contains([
      "PriceClass_All",
      "PriceClass_200",
      "PriceClass_100"
    ], var.price_class)
    error_message = "Valid values are limited to (null, PriceClass_All, PriceClass_200, PriceClass_100)."
  }
  default = null
}

variable "origin_shield" {
  type = list(object({
    enabled              = bool
    origin_shield_region = string

  }))
  description = <<EOT
  The [CloudFront Origin Shield](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#origin-shield-arguments) configuration information.
  Using Origin Shield can help reduce the load on your origin.
  For more information, see [Using Origin Shield](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html) in the Amazon CloudFront Developer Guide.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#origin-shield-arguments) carefully.
  Default values for the options are:
```
  default = [{
    # (Required) - A boolean that specifies whether Origin Shield is enabled.
    enabled              = null

    # (Required) - The AWS Region for Origin Shield. To specify a region, use the region code, not the region name.
    # For example, specify the US East (Ohio) region as **us-east-2**.
    origin_shield_region = null
  }]
```
  EOT
  default = [{
    enabled              = null
    origin_shield_region = null
  }]

}

variable "restrictions" {
  type        = any
  description = <<EOT
  (Required if not accepting the defaults) - The [restriction configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#restrictions-arguments) for this distribution (maximum one).

  Note that this variable overrides the values in `local.restrictions_defaults`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#restrictions-arguments) carefully.
  Default values for the options are:
```
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
```
  EOT
  default     = null
}
variable "retain_on_delete" {
  type        = bool
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set to `true`, the distribution needs to be deleted manually afterwards."
  default     = false
}

variable "s3_origin_config" {
  type = list(object({
    origin_access_identity = string
  }))
  description = <<EOT
  One of either this, or `var.custom_origin_config` is REQUIRED.
  NOTE - All values must be provided, even if that value is `null`.

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#s3-origin-config-arguments) carefully.
  Default values for the options are:
```
  default = [{
    # (Optional) - The [CloudFront origin access identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) to associate with the origin.
    origin_access_identity = null
 }]
```
  EOT
  default = [{
    origin_access_identity = null
  }]
}

variable "shield_advanced_protection" {
  type        = bool
  description = "Whether or not to enable advanced protection for the created CloudFront distribution. Defaults to `false`. Please note that this requires additional subscription to the Shield Advanced Protection service."
  default     = false
}

variable "viewer_certificate" {
  type        = map(string)
  description = <<EOT
  REQUIRED variable.

  Note that this variable overrides the values in `local.viewer_certificate_defaults`

  Please review all the [options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer-certificate-arguments) carefully.
  Default values for the options are:
```
  local.viewer_certificate_defaults = {
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
    minimum_protocol_version = "TLSv1.2_2018"

    # Specifies how you want CloudFront to serve HTTPS requests. One of **vip** or **sni-only**. Required if you specify **acm_certificate_arn** or **iam_certificate_id**.
    # NOTE: **vip** causes CloudFront to use a dedicated IP address and may incur extra charges.
    ssl_support_method = "sni-only"
  }
```
  EOT
}

variable "wait_for_deployment" {
  type        = bool
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this to `false` will skip the process."
  default     = true
}

variable "web_acl_id" {
  type        = string
  description = <<EOT
  (Optional) - A unique identifier that specifies the AWS WAF web ACL, if any, to associate with this distribution.

  To specify a web ACL created using the latest version of AWS WAF (WAFv2), use the ACL ARN, for example `aws_wafv2_web_acl.example.arn`.
  To specify a web ACL created using AWS WAF Classic, use the ACL ID, for example `aws_waf_web_acl.example.id`.
  The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have `waf:GetWebACL` permissions assigned.
  EOT
  default     = null
}
