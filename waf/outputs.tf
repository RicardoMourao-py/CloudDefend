output "rule_group_id" {
  description = "AWS WAF Rule Group which contains all rules for OWASP Top 10 protection."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule_group.owasp_top_10.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule_group.owasp_top_10.*.id, list("NOT_CREATED")), "0")}"
}

output "rule01_sql_injection_rule_id" {
  description = "AWS WAF Rule which mitigates SQL Injection Attacks."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_01_sql_injection_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_01_sql_injection_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule02_auth_token_rule_id" {
  description = "AWS WAF Rule which blacklists bad/hijacked JWT tokens or session IDs."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_02_auth_token_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_02_auth_token_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule03_xss_rule_id" {
  description = "AWS WAF Rule which mitigates Cross Site Scripting Attacks."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_03_xss_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_03_xss_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule04_paths_rule_id" {
  description = "AWS WAF Rule which mitigates Path Traversal, LFI, RFI."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_04_paths_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_04_paths_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule06_php_insecure_rule_id" {
  description = "AWS WAF Rule which mitigates PHP Specific Security Misconfigurations."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_06_php_insecure_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_06_php_insecure_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule07_size_restriction_rule_id" {
  description = "AWS WAF Rule which mitigates abnormal requests via size restrictions."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_07_size_restriction_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_07_size_restriction_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule08_csrf_rule_id" {
  description = "AWS WAF Rule which enforces the presence of CSRF token in request header."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_08_csrf_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_08_csrf_rule.*.id, list("NOT_CREATED")), "0")}"
}

output "rule09_server_side_include_rule_id" {
  description = "AWS WAF Rule which blocks request patterns for webroot objects that shouldn't be directly accessible."
  value       = "${lower(var.target_scope) == "regional" ? element(concat(aws_wafregional_rule.owasp_09_server_side_include_rule.*.id, tolist(["NOT_CREATED"])), "0") : element(concat(aws_waf_rule.owasp_09_server_side_include_rule.*.id, list("NOT_CREATED")), "0")}"
}