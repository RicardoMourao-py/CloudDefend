variable "product_domain" {
  type        = string
  description = "The name of the product domain these resources belong to."
}

variable "service_name" {
  type        = string
  description = "The name of the service these resources belong to."
}

variable "environment" {
  type        = string
  description = "The environment of these resources belong to."
}

variable "description" {
  type        = string
  description = "The description of these resources."
}

variable "target_scope" {
  type        = string
  description = "Valid values are `global` and `regional`. If `global`, means resources created will be for global targets such as Amazon CloudFront distribution. For regional targets like ALBs and API Gateway stages, set to `regional`"
}

variable "create_rule_group" {
  type        = string
  description = "All rules can be grouped into a Rule Group. Unfortunately, AWS WAF Rule Group limit per region is only 3. By setting the value to `false` will not create the rule group. Default to `true`."
  default     = "true"
}

variable "max_expected_uri_size" {
  type        = string
  description = "Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application."
  default     = "2048"
}

variable "max_expected_query_string_size" {
  type        = string
  description = "Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the ? in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values."
  default     = "5096"
}

variable "max_expected_body_size" {
  type        = string
  description = "Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application."
  default     = "16384"
}

variable "max_expected_cookie_size" {
  type        = string
  description = "Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata."
  default     = "4093"
}

variable "csrf_expected_header" {
  type        = string
  description = "The custom HTTP request header, where the CSRF token value is expected to be encountered"
  default     = "x-csrf-token"
}

variable "csrf_expected_size" {
  type        = string
  description = "The size in bytes of the CSRF token value. For example if it's a canonically formatted UUIDv4 value the expected size would be 36 bytes/ASCII characters."
  default     = "36"
}