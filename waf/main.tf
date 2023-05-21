# Provide AWS Credentials
provider "aws" {
  region = "us-east-1"
}

# Random ID Generator

resource "random_id" "this" {
  count = "${lower(var.target_scope) == "regional" || lower(var.target_scope) == "global" ? "1" : "0"}"

  byte_length = "8"

  keepers = {
    target_scope = "${lower(var.target_scope)}"
  }
}

# Regional

## OWASP Top 10 A1
### Mitigate SQL Injection Attacks
### Matches attempted SQLi patterns in the URI, QUERY_STRING, BODY, COOKIES
resource "aws_wafregional_sql_injection_match_set" "owasp_01_sql_injection_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-01-detect-sql-injection-${random_id.this.0.hex}"

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }
}

resource "aws_wafregional_rule" "owasp_01_sql_injection_rule" {
  depends_on = [aws_wafregional_sql_injection_match_set.owasp_01_sql_injection_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-01-mitigate-sql-injection-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP01MitigateSQLInjection${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_sql_injection_match_set.owasp_01_sql_injection_set.0.id}"
    negated = "false"
    type    = "SqlInjectionMatch"
  }
}

## OWASP Top 10 A2
### Blacklist bad/hijacked JWT tokens or session IDs
### Matches the specific values in the cookie or Authorization header for JWT it is sufficient to check the signature
resource "aws_wafregional_byte_match_set" "owasp_02_auth_token_string_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-02-match-auth-token-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "example-session-id"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }
}

resource "aws_wafregional_rule" "owasp_02_auth_token_rule" {
  depends_on = [aws_wafregional_byte_match_set.owasp_02_auth_token_string_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-02-detect-bad-auth-token-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP02BadAuthToken${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.owasp_02_auth_token_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## OWASP Top 10 A3
### Mitigate Cross Site Scripting Attacks
### Matches attempted XSS patterns in the URI, QUERY_STRING, BODY, COOKIES
resource "aws_wafregional_xss_match_set" "owasp_03_xss_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-03-detect-xss-${random_id.this.0.hex}"

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

resource "aws_wafregional_rule" "owasp_03_xss_rule" {
  depends_on = [aws_wafregional_xss_match_set.owasp_03_xss_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-03-mitigate-xss-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP03MitigateXSS${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_xss_match_set.owasp_03_xss_set.0.id}"
    negated = "false"
    type    = "XssMatch"
  }
}

## OWASP Top 10 A4
### Path Traversal, LFI, RFI
### Matches request patterns designed to traverse filesystem paths, and include local or remote files
resource "aws_wafregional_byte_match_set" "owasp_04_paths_string_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-04-match-rfi-lfi-traversal-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_wafregional_rule" "owasp_04_paths_rule" {
  depends_on = [aws_wafregional_byte_match_set.owasp_04_paths_string_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-04-detect-rfi-lfi-traversal-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP04DetectRFILFITraversal${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.owasp_04_paths_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## OWASP Top 10 A4
## Privileged Module Access Restrictions
## Restrict access to the admin interface to known source IPs only
## Matches the URI prefix, when the remote IP isn't in the whitelist
## CURRENTLY NOT APPLICABLE

## OWASP Top 10 A5
## PHP Specific Security Misconfigurations
## Matches request patterns designed to exploit insecure PHP/CGI configuration
resource "aws_wafregional_byte_match_set" "owasp_06_php_insecure_qs_string_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-06-match-php-insecure-var-refs-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "_SERVER["
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "_ENV["
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "auto_prepend_file="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "auto_append_file="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "allow_url_include="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "disable_functions="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "open_basedir="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "safe_mode="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_wafregional_byte_match_set" "owasp_06_php_insecure_uri_string_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-06-match-php-insecure-uri-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "php"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "/"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_rule" "owasp_06_php_insecure_rule" {
  depends_on = [aws_wafregional_byte_match_set.owasp_06_php_insecure_qs_string_set, aws_wafregional_byte_match_set.owasp_06_php_insecure_uri_string_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-06-detect-php-insecure-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP06DetectPHPInsecure${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.owasp_06_php_insecure_qs_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }

  predicate {
    data_id = "${aws_wafregional_byte_match_set.owasp_06_php_insecure_uri_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## OWASP Top 10 A7
### Mitigate abnormal requests via size restrictions
### Enforce consistent request hygene, limit size of key elements
resource "aws_wafregional_size_constraint_set" "owasp_07_size_restriction_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-07-size-restrictions-${random_id.this.0.hex}"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_uri_size}"

    field_to_match {
      type = "URI"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_query_string_size}"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_body_size}"

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_cookie_size}"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

resource "aws_wafregional_rule" "owasp_07_size_restriction_rule" {
  depends_on = [aws_wafregional_size_constraint_set.owasp_07_size_restriction_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-07-restrict-sizes-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP07RestrictSizes${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_size_constraint_set.owasp_07_size_restriction_set.0.id}"
    negated = "false"
    type    = "SizeConstraint"
  }
}

## OWASP Top 10 A8
### CSRF token enforcement example
### Enforce the presence of CSRF token in request header
resource "aws_wafregional_byte_match_set" "owasp_08_csrf_method_string_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-08-match-csrf-method-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "post"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "METHOD"
    }
  }
}

resource "aws_wafregional_size_constraint_set" "owasp_08_csrf_token_size_constrain_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-08-csrf-token-size-${random_id.this.0.hex}"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size                = "${var.csrf_expected_size}"

    field_to_match {
      type = "HEADER"
      data = "${var.csrf_expected_header}"
    }
  }
}

resource "aws_wafregional_rule" "owasp_08_csrf_rule" {
  depends_on = [aws_wafregional_byte_match_set.owasp_08_csrf_method_string_set, aws_wafregional_size_constraint_set.owasp_08_csrf_token_size_constrain_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-08-enforce-csrf-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP08EnforceCSRF${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.owasp_08_csrf_method_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }

  predicate {
    data_id = "${aws_wafregional_size_constraint_set.owasp_08_csrf_token_size_constrain_set.0.id}"
    negated = "false"
    type    = "SizeConstraint"
  }
}

## OWASP Top 10 A9
### Server-side includes & libraries in webroot
### Matches request patterns for webroot objects that shouldn't be directly accessible
resource "aws_wafregional_byte_match_set" "owasp_09_server_side_include_string_set" {
  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-09-match-ssi-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".cfg"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".conf"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".config"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".ini"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".log"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".bak"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".backup"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_rule" "owasp_09_server_side_include_rule" {
  depends_on = [aws_wafregional_byte_match_set.owasp_09_server_side_include_string_set]

  count = "${lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-09-detect-ssi-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP09DetectSSI${random_id.this.0.hex}"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.owasp_09_server_side_include_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## 10. ## Generic
### IP Blacklist
### Matches IP addresses that should not be allowed to access content
### CURRENTLY NOT APPLICABLE

## RuleGroup

resource "aws_wafregional_rule_group" "owasp_top_10" {
  depends_on = [
    aws_wafregional_rule.owasp_01_sql_injection_rule,
    aws_wafregional_rule.owasp_02_auth_token_rule,
    aws_wafregional_rule.owasp_03_xss_rule,
    aws_wafregional_rule.owasp_04_paths_rule,
    aws_wafregional_rule.owasp_06_php_insecure_rule,
    aws_wafregional_rule.owasp_07_size_restriction_rule,
    aws_wafregional_rule.owasp_08_csrf_rule,
    aws_wafregional_rule.owasp_09_server_side_include_rule,
  ]

  count = "${lower(var.create_rule_group) && lower(var.target_scope) == "regional" ? "1" : "0"}"

  name        = "${format("%s-owasp-top-10-%s", lower(var.service_name), random_id.this.0.hex)}"
  metric_name = "${format("%sOWASPTop10%s", lower(var.service_name), random_id.this.0.hex)}"

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "1"
    rule_id  = "${aws_wafregional_rule.owasp_07_size_restriction_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "2"
    rule_id  = "${aws_wafregional_rule.owasp_02_auth_token_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "3"
    rule_id  = "${aws_wafregional_rule.owasp_01_sql_injection_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "4"
    rule_id  = "${aws_wafregional_rule.owasp_03_xss_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "5"
    rule_id  = "${aws_wafregional_rule.owasp_04_paths_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "6"
    rule_id  = "${aws_wafregional_rule.owasp_06_php_insecure_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "7"
    rule_id  = "${aws_wafregional_rule.owasp_08_csrf_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "8"
    rule_id  = "${aws_wafregional_rule.owasp_09_server_side_include_rule.0.id}"
    type     = "REGULAR"
  }
}

# Global

## OWASP Top 10 A1
### Mitigate SQL Injection Attacks
### Matches attempted SQLi patterns in the URI, QUERY_STRING, BODY, COOKIES
resource "aws_waf_sql_injection_match_set" "owasp_01_sql_injection_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-01-detect-sql-injection-${random_id.this.0.hex}"

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }

  sql_injection_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }
}

resource "aws_waf_rule" "owasp_01_sql_injection_rule" {
  depends_on = [aws_waf_sql_injection_match_set.owasp_01_sql_injection_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-01-mitigate-sql-injection-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP01MitigateSQLInjection${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_sql_injection_match_set.owasp_01_sql_injection_set.0.id}"
    negated = "false"
    type    = "SqlInjectionMatch"
  }
}

## OWASP Top 10 A2
### Blacklist bad/hijacked JWT tokens or session IDs
### Matches the specific values in the cookie or Authorization header for JWT it is sufficient to check the signature
resource "aws_waf_byte_match_set" "owasp_02_auth_token_string_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-02-match-auth-token-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "example-session-id"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }
}

resource "aws_waf_rule" "owasp_02_auth_token_rule" {
  depends_on = [aws_waf_byte_match_set.owasp_02_auth_token_string_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-02-detect-bad-auth-token-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP02BadAuthToken${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_byte_match_set.owasp_02_auth_token_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## OWASP Top 10 A3
### Mitigate Cross Site Scripting Attacks
### Matches attempted XSS patterns in the URI, QUERY_STRING, BODY, COOKIES
resource "aws_waf_xss_match_set" "owasp_03_xss_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-03-detect-xss-${random_id.this.0.hex}"

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  xss_match_tuples {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  xss_match_tuples {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

resource "aws_waf_rule" "owasp_03_xss_rule" {
  depends_on = [aws_waf_xss_match_set.owasp_03_xss_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-03-mitigate-xss-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP03MitigateXSS${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_xss_match_set.owasp_03_xss_set.0.id}"
    negated = "false"
    type    = "XssMatch"
  }
}

## OWASP Top 10 A4
### Path Traversal, LFI, RFI
### Matches request patterns designed to traverse filesystem paths, and include local or remote files
resource "aws_waf_byte_match_set" "owasp_04_paths_string_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-04-match-rfi-lfi-traversal-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_waf_rule" "owasp_04_paths_rule" {
  depends_on = [aws_waf_byte_match_set.owasp_04_paths_string_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-04-detect-rfi-lfi-traversal-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP04DetectRFILFITraversal${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_byte_match_set.owasp_04_paths_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## OWASP Top 10 A4
## Privileged Module Access Restrictions
## Restrict access to the admin interface to known source IPs only
## Matches the URI prefix, when the remote IP isn't in the whitelist
## CURRENTLY NOT APPLICABLE

## OWASP Top 10 A5
## PHP Specific Security Misconfigurations
## Matches request patterns designed to exploit insecure PHP/CGI configuration
resource "aws_waf_byte_match_set" "owasp_06_php_insecure_qs_string_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-06-match-php-insecure-var-refs-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "_SERVER["
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "_ENV["
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "auto_prepend_file="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "auto_append_file="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "allow_url_include="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "disable_functions="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "open_basedir="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "safe_mode="
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_waf_byte_match_set" "owasp_06_php_insecure_uri_string_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-06-match-php-insecure-uri-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "php"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "/"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_waf_rule" "owasp_06_php_insecure_rule" {
  depends_on = [aws_waf_byte_match_set.owasp_06_php_insecure_qs_string_set, aws_waf_byte_match_set.owasp_06_php_insecure_uri_string_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-06-detect-php-insecure-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP06DetectPHPInsecure${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_byte_match_set.owasp_06_php_insecure_qs_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }

  predicates {
    data_id = "${aws_waf_byte_match_set.owasp_06_php_insecure_uri_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## OWASP Top 10 A7
### Mitigate abnormal requests via size restrictions
### Enforce consistent request hygene, limit size of key elements
resource "aws_waf_size_constraint_set" "owasp_07_size_restriction_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-07-size-restrictions-${random_id.this.0.hex}"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_uri_size}"

    field_to_match {
      type = "URI"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_query_string_size}"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_body_size}"

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "${var.max_expected_cookie_size}"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

resource "aws_waf_rule" "owasp_07_size_restriction_rule" {
  depends_on = [aws_waf_size_constraint_set.owasp_07_size_restriction_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-07-restrict-sizes-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP07RestrictSizes${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_size_constraint_set.owasp_07_size_restriction_set.0.id}"
    negated = "false"
    type    = "SizeConstraint"
  }
}

## OWASP Top 10 A8
### CSRF token enforcement example
### Enforce the presence of CSRF token in request header
resource "aws_waf_byte_match_set" "owasp_08_csrf_method_string_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-08-match-csrf-method-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "post"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "METHOD"
    }
  }
}

resource "aws_waf_size_constraint_set" "owasp_08_csrf_token_size_constrain_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-08-csrf-token-size-${random_id.this.0.hex}"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "EQ"
    size                = "${var.csrf_expected_size}"

    field_to_match {
      type = "HEADER"
      data = "${var.csrf_expected_header}"
    }
  }
}

resource "aws_waf_rule" "owasp_08_csrf_rule" {
  depends_on = [aws_waf_byte_match_set.owasp_08_csrf_method_string_set, aws_waf_size_constraint_set.owasp_08_csrf_token_size_constrain_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-08-enforce-csrf-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP08EnforceCSRF${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_byte_match_set.owasp_08_csrf_method_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }

  predicates {
    data_id = "${aws_waf_size_constraint_set.owasp_08_csrf_token_size_constrain_set.0.id}"
    negated = "false"
    type    = "SizeConstraint"
  }
}

## OWASP Top 10 A9
### Server-side includes & libraries in webroot
### Matches request patterns for webroot objects that shouldn't be directly accessible
resource "aws_waf_byte_match_set" "owasp_09_server_side_include_string_set" {
  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name = "${lower(var.service_name)}-owasp-09-match-ssi-${random_id.this.0.hex}"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".cfg"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".conf"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".config"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".ini"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".log"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".bak"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".backup"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_waf_rule" "owasp_09_server_side_include_rule" {
  depends_on = [aws_waf_byte_match_set.owasp_09_server_side_include_string_set]

  count = "${lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${lower(var.service_name)}-owasp-09-detect-ssi-${random_id.this.0.hex}"
  metric_name = "${lower(var.service_name)}OWASP09DetectSSI${random_id.this.0.hex}"

  predicates {
    data_id = "${aws_waf_byte_match_set.owasp_09_server_side_include_string_set.0.id}"
    negated = "false"
    type    = "ByteMatch"
  }
}

## 10. ## Generic
### IP Blacklist
### Matches IP addresses that should not be allowed to access content
### CURRENTLY NOT APPLICABLE

## RuleGroup

resource "aws_waf_rule_group" "owasp_top_10" {
  depends_on = [
    aws_waf_rule.owasp_01_sql_injection_rule,
    aws_waf_rule.owasp_02_auth_token_rule,
    aws_waf_rule.owasp_03_xss_rule,
    aws_waf_rule.owasp_04_paths_rule,
    aws_waf_rule.owasp_06_php_insecure_rule,
    aws_waf_rule.owasp_07_size_restriction_rule,
    aws_waf_rule.owasp_08_csrf_rule,
    aws_waf_rule.owasp_09_server_side_include_rule,
  ]

  count = "${lower(var.create_rule_group) && lower(var.target_scope) == "global" ? "1" : "0"}"

  name        = "${format("%s-owasp-top-10-%s", lower(var.service_name), random_id.this.0.hex)}"
  metric_name = "${format("%sOWASPTop10%s", lower(var.service_name), random_id.this.0.hex)}"

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "1"
    rule_id  = "${aws_waf_rule.owasp_07_size_restriction_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "2"
    rule_id  = "${aws_waf_rule.owasp_02_auth_token_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "3"
    rule_id  = "${aws_waf_rule.owasp_01_sql_injection_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "4"
    rule_id  = "${aws_waf_rule.owasp_03_xss_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "5"
    rule_id  = "${aws_waf_rule.owasp_04_paths_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "6"
    rule_id  = "${aws_waf_rule.owasp_06_php_insecure_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "7"
    rule_id  = "${aws_waf_rule.owasp_08_csrf_rule.0.id}"
    type     = "REGULAR"
  }

  activated_rule {
    action {
      type = "BLOCK"
    }

    priority = "8"
    rule_id  = "${aws_waf_rule.owasp_09_server_side_include_rule.0.id}"
    type     = "REGULAR"
  }
}